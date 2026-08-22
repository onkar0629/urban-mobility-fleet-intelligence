import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry


class GBFSClient:
    """Client used to discover and retrieve GBFS feeds."""

    def __init__(
        self,
        discovery_url: str,
        timeout: int = 30,
        retries: int = 3,
        backoff_factor: float = 1.0
    ):
        self.discovery_url = discovery_url
        self.timeout = timeout
        self.session = requests.Session()

        self.headers = {
            "User-Agent": (
                "UrbanMobilityFleetIntelligence/1.0 "
                "(Data Engineering Project)"
            ),
            "Accept": "application/json",
        }

        retry_policy = Retry(
            total=retries,
            connect=retries,
            read=retries,
            status=retries,
            backoff_factor=backoff_factor,
            status_forcelist=(429, 500, 502, 503, 504),
            allowed_methods=("GET",)
        )

        adapter = HTTPAdapter(max_retries=retry_policy)
        self.session.mount("https://", adapter)
        self.session.mount("http://", adapter)

    def discover_feeds(self) -> dict:
        """Retrieve the GBFS discovery document."""

        response = self.session.get(
            self.discovery_url,
            headers=self.headers,
            timeout=self.timeout
        )

        response.raise_for_status()

        return response.json()

    def get_feed_urls(self) -> dict:
        """Build a mapping of GBFS feed names to URLs."""

        discovery_data = self.discover_feeds()

        feeds = (
            discovery_data
            .get("data", {})
            .get("en", {})
            .get("feeds", [])
        )

        return {
            feed["name"]: feed["url"]
            for feed in feeds
        }

    def fetch_feed(self, feed_name: str) -> dict:
        """Fetch a specific GBFS feed."""

        feed_urls = self.get_feed_urls()

        if feed_name not in feed_urls:
            raise ValueError(
                f"GBFS feed not found: {feed_name}"
            )

        response = self.session.get(
            feed_urls[feed_name],
            headers=self.headers,
            timeout=self.timeout
        )

        response.raise_for_status()

        return response.json()
