#!/usr/bin/env python
"""Starter PySpark job: GBFS Bronze JSON -> Silver and quarantine.

GBFS feeds have different nested shapes. This job preserves the source envelope
and lineage; validate feed-specific requirements before production use.
"""
import argparse

from pyspark.sql import SparkSession, functions as F


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input-path', required=True)
    parser.add_argument('--silver-path', required=True)
    parser.add_argument('--quarantine-path', required=True)
    parser.add_argument('--write-mode', choices=('append', 'overwrite'), default='append')
    parser.add_argument('--multiline', choices=('true', 'false'), default='true')
    return parser.parse_args()


def main():
    args = parse_args()
    spark = SparkSession.builder.appName('umfi-gbfs-bronze-to-silver').getOrCreate()
    try:
        source = (
            spark.read.option('multiLine', args.multiline == 'true')
            .option('mode', 'PERMISSIVE')
            .json(args.input_path)
        )
        if not source.columns:
            raise ValueError('No JSON fields found. Check the input path and JSON structure.')

        df = source.withColumn('_source_file', F.input_file_name()).withColumn('_processed_at', F.current_timestamp())
        # Placeholder validation only: feed-specific checks require inspecting the GBFS schema.
        all_null = None
        for col_name in source.columns:
            condition = F.col(col_name).isNull()
            all_null = condition if all_null is None else (all_null & condition)
        df = df.withColumn('_quality_issue', F.when(all_null, F.lit('all_top_level_fields_null')))

        rejected = df.filter(F.col('_quality_issue').isNotNull())
        accepted = df.filter(F.col('_quality_issue').isNull())
        accepted.write.format('parquet').mode(args.write_mode).save(args.silver_path)
        rejected.write.format('parquet').mode(args.write_mode).save(args.quarantine_path)

        input_count = df.count()
        accepted_count = accepted.count()
        rejected_count = rejected.count()
        print({
            'job': 'umfi-gbfs-bronze-to-silver',
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
