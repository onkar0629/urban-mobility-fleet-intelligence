from config import GBFS_DISCOVERY_URL, FEEDS, OUTPUT_DIR
from gbfs_client import GBFSClient
from validator import validate_gbfs_response, validate_feed_records
from file_writer import save_json


def main():
    client = GBFSClient(GBFS_DISCOVERY_URL)

    feed_urls = client.get_feed_urls()

    for feed_name in FEEDS:

        print(f"Fetching {feed_name}...")

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

            print(
                f"Successfully saved: {file_path}"
            )

        except Exception as error:
            print(
                f"Failed to process {feed_name}: {error}"
            )


if __name__ == "__main__":
    main()