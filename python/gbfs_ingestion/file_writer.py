import json
from datetime import datetime, timezone
from pathlib import Path
from uuid import uuid4


def save_json(
    data: dict,
    output_dir: Path,
    feed_name: str,
    source_url: str = ""
) -> Path:
    """
    Save a GBFS response as a timestamped JSON snapshot.

    The original GBFS payload is preserved under the
    'data' key, while ingestion metadata is added
    for lineage and traceability.
    """

    output_dir.mkdir(
        parents=True,
        exist_ok=True
    )

    ingestion_timestamp = datetime.now(
        timezone.utc
    )

    timestamp = ingestion_timestamp.strftime(
        "%Y%m%dT%H%M%SZ"
    )

    load_id = str(uuid4())

    file_name = f"{feed_name}_{timestamp}.json"

    file_path = output_dir / file_name

    output = {
        "ingestion_metadata": {
            "source_system": "DIVVY_GBFS",
            "feed_name": feed_name,
            "source_url": source_url,
            "load_id": load_id,
            "ingestion_timestamp": (
                ingestion_timestamp.isoformat()
            )
        },
        "data": data.get("data", data)
    }

    with file_path.open(
        "w",
        encoding="utf-8"
    ) as file:
        json.dump(
            output,
            file,
            indent=2
        )

    return file_path