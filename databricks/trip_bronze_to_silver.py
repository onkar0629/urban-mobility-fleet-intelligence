#!/usr/bin/env python
"""Starter PySpark job: historical trips Bronze CSV -> Silver and quarantine.

Run on Databricks Runtime or with spark-submit in a compatible Spark environment.
Review aliases, types, and required fields against the actual source dataset.
"""
import argparse
import re

from pyspark.sql import SparkSession, functions as F


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input-path', required=True)
    parser.add_argument('--silver-path', required=True)
    parser.add_argument('--quarantine-path', required=True)
    parser.add_argument('--write-mode', choices=('append', 'overwrite'), default='append')
    return parser.parse_args()


def normalize_column_name(name: str) -> str:
    name = re.sub(r'[^a-zA-Z0-9]+', '_', name.strip().lower())
    return re.sub(r'_+', '_', name).strip('_')


def main():
    args = parse_args()
    spark = SparkSession.builder.appName('umfi-trips-bronze-to-silver').getOrCreate()
    try:
        source = spark.read.option('header', True).option('mode', 'PERMISSIVE').csv(args.input_path)
        if not source.columns:
            raise ValueError('Input contains no columns or could not be read.')

        df = source
        for original in source.columns:
            normalized = normalize_column_name(original)
            if normalized and original != normalized:
                df = df.withColumnRenamed(original, normalized)

        cols = set(df.columns)
        start_col = next((c for c in ('started_at', 'start_time', 'starttime', 'started') if c in cols), None)
        end_col = next((c for c in ('ended_at', 'end_time', 'stoptime', 'ended') if c in cols), None)
        id_col = next((c for c in ('ride_id', 'trip_id') if c in cols), None)

        df = df.withColumn('_source_file', F.input_file_name()).withColumn('_processed_at', F.current_timestamp())
        issues = []
        for col_name in (id_col, start_col, end_col):
            if col_name:
                issues.append(F.col(col_name).isNull() | (F.trim(F.col(col_name).cast('string')) == ''))

        if issues:
            any_issue = issues[0]
            for issue in issues[1:]:
                any_issue = any_issue | issue
            df = df.withColumn('_quality_issue', F.when(any_issue, F.lit('missing_required_value')))
        else:
            df = df.withColumn('_quality_issue', F.lit('source_schema_review_required'))

        if start_col:
            df = df.withColumn('started_at_normalized', F.to_timestamp(F.col(start_col)))
        if end_col:
            df = df.withColumn('ended_at_normalized', F.to_timestamp(F.col(end_col)))

        rejected = df.filter(F.col('_quality_issue').isNotNull())
        accepted = df.filter(F.col('_quality_issue').isNull())
        # Persist outputs before collecting counts to avoid re-reading source repeatedly.
        accepted.write.format('parquet').mode(args.write_mode).save(args.silver_path)
        rejected.write.format('parquet').mode(args.write_mode).save(args.quarantine_path)

        input_count = df.count()
        accepted_count = accepted.count()
        rejected_count = rejected.count()
        print({
            'job': 'umfi-trips-bronze-to-silver',
            'input_rows': input_count,
            'accepted_rows': accepted_count,
            'rejected_rows': rejected_count,
            'silver_path': args.silver_path,
            'quarantine_path': args.quarantine_path,
        })
        if input_count != accepted_count + rejected_count:
            raise RuntimeError('Count reconciliation failed.')
    finally:
        spark.stop()


if __name__ == '__main__':
    main()
