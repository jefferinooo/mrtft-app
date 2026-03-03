from fastapi import APIRouter, HTTPException
import httpx
from app.core.config import settings

router = APIRouter(tags=["riot-test"])

@router.get("/test-riot/{game_name}/{tag_line}")
def test_riot(game_name: str, tag_line: str):
    url = (
        f"https://{settings.RIOT_REGION}.api.riotgames.com/"
        f"riot/account/v1/accounts/by-riot-id/{game_name}/{tag_line}"
    )

    headers = {"X-Riot-Token": settings.RIOT_API_KEY}

    response = httpx.get(url, headers=headers)

    if response.status_code != 200:
        raise HTTPException(status_code=response.status_code, detail=response.text)

    return response.json()