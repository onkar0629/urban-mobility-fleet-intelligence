from typing import Any


def validate_gbfs_response(data: dict, feed_name: str) -> None:
    """
    Validate the basic structure of a GBFS response.

    Raises:
        ValueError: If the response does not match the
                    expected GBFS structure.
    """

    if not isinstance(data, dict):
        raise ValueError(
            f"{feed_name}: response must be a JSON object."
        )

    if "last_updated" not in data:
        raise ValueError(
            f"{feed_name}: missing 'last_updated'."
        )

    if "ttl" not in data:
        raise ValueError(
            f"{feed_name}: missing 'ttl'."
        )

    if "data" not in data:
        raise ValueError(
            f"{feed_name}: missing 'data'."
        )

    if not isinstance(data["data"], dict):
        raise ValueError(
            f"{feed_name}: 'data' must be a JSON object."
        )


def validate_feed_records(
    data: dict,
    feed_name: str,
    record_key: str
) -> None:
    """
    Validate that the expected record collection exists
    inside the GBFS data section.
    """

    records: Any = data["data"].get(record_key)

    if records is None:
        raise ValueError(
            f"{feed_name}: missing '{record_key}' in data."
        )

    if not isinstance(records, list):
        raise ValueError(
            f"{feed_name}: '{record_key}' must be a list."
        )