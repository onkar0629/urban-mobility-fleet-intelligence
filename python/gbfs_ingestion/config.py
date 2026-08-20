from pathlib import Path


# ============================================================
# GBFS CONFIGURATION
# ============================================================

GBFS_DISCOVERY_URL = (
    "https://gbfs.divvybikes.com/gbfs/gbfs.json"
)

OUTPUT_DIR = Path(__file__).resolve().parent / "output"

FEEDS = {
    "station_status": "station_status",
    "free_bike_status": "free_bike_status",
}