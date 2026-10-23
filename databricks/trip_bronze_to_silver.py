#!/usr/bin/env python
"""Starter job for cleaning historical trip CSV files with PySpark.

Check the source schema before running this job on a real dataset.
"""
import argparse
import re

from pyspark.sql import SparkSession, functions as F


def parse_args():
    parser = argparse.ArgumentParser(description="Clean trip CSV files with PySpark.")
    parser.add_argument("--input-path", required=True, help="Bronze CSV file or directory")
    parser.add_argument("--silver-path", required=True, help="Output path for accepted records")
    parser.add_argument("--quarantine-path", required=True, help="Output path for rejected records")
    parser.add_argument("--write-mode", choices=("append", "overwrite"), default="append")
    return parser.parse_args()


def normalize_column_name(name):
    name = re.sub(r"[^a-zA-Z0-9]+", "_", name.strip().lower())
    return re.sub(r"_+", "_", name).strip("_")


def main():
    args = parse_args()
    spark = SparkSession.builder.appName("umfi-trips-bronze-to-silver").getOrCreate()

    try:
        source = (
            spark.read.option("header", True)
            .option("mode", "PERMISSIVE")
            .csv(args.input_path)
        )
        if not source.columns:
            raise ValueError("No columns found. Check the input path and CSV header.")

        df = source
        for original in source.columns:
            normalized = normalize_column_name(original)
            if normalized and original != normalized:
                df = df.withColumnRenamed(original, normalized)

        columns = set(df.columns)
        start_col = next(
            (name for name in ("started_at", "start_time", "starttime", "start_date") if name in columns),
            None,
        )
        end_col = next(
            (name for name in ("ended_at", "end_time", "endtime", "stop_time", "stoptime", "end_date") if name in columns),
            None,
        )
        id_col = next((name for name in ("ride_id", "trip_id") if name in columns), None)

        # Fail clearly when the input does not match the supported starter schema.
        if not start_col or not end_col:
            raise ValueError(
                "Could not identify trip start/end columns. "
                f"Found columns: {sorted(columns)}. Update the column aliases for this dataset."
            )

        df = (
            df.withColumn("_source_file", F.input_file_name())
            .withColumn("_processed_at", F.current_timestamp())
            .withColumn("started_at_normalized", F.to_timestamp(F.col(start_col)))
            .withColumn("ended_at_normalized", F.to_timestamp(F.col(end_col)))
        )

        issue = (
            F.col(start_col).isNull()
            | (F.trim(F.col(start_col).cast("string")) == "")
            | F.col(end_col).isNull()
            | (F.trim(F.col(end_col).cast("string")) == "")
            | F.col("started_at_normalized").isNull()
            | F.col("ended_at_normalized").isNull()
        )
        if id_col:
            issue = issue | F.col(id_col).isNull() | (F.trim(F.col(id_col).cast("string")) == "")

        df = df.withColumn(
            "_quality_issue",
            F.when(issue, F.lit("missing_or_invalid_trip_identifier_or_timestamp")),
        )
        accepted = df.filter(F.col("_quality_issue").isNull())
        rejected = df.filter(F.col("_quality_issue").isNotNull())

        # Use a test output path first. Append mode can duplicate data on a rerun.
        accepted.write.format("parquet").mode(args.write_mode).save(args.silver_path)
        rejected.write.format("parquet").mode(args.write_mode).save(args.quarantine_path)

        input_count = df.count()
        accepted_count = accepted.count()
        rejected_count = rejected.count()
        print({
            "job": "umfi-trips-bronze-to-silver",
            "input_rows": input_count,
            "accepted_rows": accepted_count,
            "rejected_rows": rejected_count,
            "silver_path": args.silver_path,
            "quarantine_path": args.quarantine_path,
        })

        if input_count != accepted_count + rejected_count:
            raise RuntimeError("Count reconciliation failed.")
    finally:
        spark.stop()


if __name__ == "__main__":
    main()
