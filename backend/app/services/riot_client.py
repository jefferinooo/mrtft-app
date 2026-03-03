import httpx
from app.core.config import settings


class RiotClient:
    """
    Low-level client for Riot endpoints.
    Keeps HTTP + URLs in one place.
    """

    def __init__(self) -> None:
        self.headers = {"X-Riot-Token": settings.RIOT_API_KEY}
        self.region = settings.RIOT_REGION      # e.g. "americas"
        self.platform = settings.RIOT_PLATFORM  # e.g. "na1"

    def get_account_by_riot_id(self, game_name: str, tag_line: str) -> dict:
        url = (
            f"https://{self.region}.api.riotgames.com/"
            f"riot/account/v1/accounts/by-riot-id/{game_name}/{tag_line}"
        )
        r = httpx.get(url, headers=self.headers, timeout=20)
        r.raise_for_status()
        return r.json()

    def get_match_ids_by_puuid(self, puuid: str, count: int = 20) -> list[str]:
        url = (
            f"https://{self.region}.api.riotgames.com/"
            f"tft/match/v1/matches/by-puuid/{puuid}/ids"
        )
        r = httpx.get(url, headers=self.headers, params={"count": count}, timeout=20)
        r.raise_for_status()
        return r.json()

    def get_match_detail(self, match_id: str) -> dict:
        url = f"https://{self.region}.api.riotgames.com/tft/match/v1/matches/{match_id}"
        r = httpx.get(url, headers=self.headers, timeout=20)
        r.raise_for_status()
        return r.json()