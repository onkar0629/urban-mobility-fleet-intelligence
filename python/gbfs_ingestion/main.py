import logging
import sys

from config import GBFS_DISCOVERY_URL, FEEDS, OUTPUT_DIR
from gbfs_client import GBFSClient
from validator import validate_gbfs_response, validate_feed_records
from file_writer import save_json


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s"
)


def main():
    client = GBFSClient(GBFS_DISCOVERY_URL)
    failed_feeds = []

    feed_urls = client.get_feed_urls()

    for feed_name in FEEDS:

        logging.info("Fetching %s", feed_name)

        try:
            data = client.fetch_feed(feed_name)

            validate_gbfs_response(
                data,
                feed_name
            )

            if feed_name == "station_status":
                validate_feed_records(
                    data,
                    feed_name,
                    "stations"
                )

            elif feed_name == "free_bike_status":
                validate_feed_records(
                    data,
                    feed_name,
                    "bikes"
                )

            source_url = feed_urls.get(feed_name, "")

            file_path = save_json(
                data,
                OUTPUT_DIR,
                feed_name,
                source_url
            )

            logging.info("Successfully saved %s", file_path)

        except Exception as error:
            failed_feeds.append(feed_name)
            logging.exception("Failed to process %s: %s", feed_name, error)

    if failed_feeds:
        raise RuntimeError(
            "GBFS ingestion failed for feeds: "
            + ", ".join(failed_feeds)
        )


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        logging.error("GBFS ingestion failed: %s", error)
        sys.exit(1)
