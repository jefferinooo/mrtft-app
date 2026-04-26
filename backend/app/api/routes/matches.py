from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.db.models.match import Match
from app.db.models.participant import Participant
from app.db.models.player import Player
from app.core.utils import format_game_length
from app.core.utils import format_game_date
from app.services.riot_client import RiotClient
from app.core.utils import normalize_riot_id_component

router = APIRouter(prefix="/matches", tags=["matches"])

@router.get("/{match_id}")
def get_match_detail(match_id: str, db: Session = Depends(get_db)):
    match = db.query(Match).filter(Match.match_id == match_id).one_or_none()

    if match is None:
        raise HTTPException(status_code=404, detail="Match not found.")

    rows = (
        db.query(Participant, Player)
        .join(Player, Participant.player_id == Player.id)
        .filter(Participant.match_id == match.id)
        .order_by(Participant.placement.asc())
        .all()
    )

    riot = RiotClient()

    participants = []

    for participant, player in rows:
        if player.game_name is None or player.tag_line is None:
            try:
                account = riot.get_account_by_puuid(player.puuid)
                print("Backfilled account:", account)

                player.game_name = normalize_riot_id_component(account.get("gameName"))
                player.tag_line = normalize_riot_id_component(account.get("tagLine"))

                db.add(player)
                db.commit()
                db.refresh(player)

            except Exception as e:
                print("Failed to backfill player:", player.puuid)
                print("Error type:", type(e))
                print("Error:", e)

        participants.append({
            "player_id": player.id,
            "puuid": player.puuid,
            "game_name": player.game_name,
            "tag_line": player.tag_line,
            "placement": participant.placement,
            "level": participant.level,
            "gold_left": participant.gold_left,
            "last_round": participant.last_round,
            "total_damage": participant.total_damage,
        })

    return {
        "match_id": match.match_id,
        "patch": match.patch,
        "queue_id": match.queue_id,
        "game_date": format_game_date(match.game_datetime),
        "game_datetime": match.game_datetime.isoformat() if match.game_datetime else None,
        "game_length_seconds": round(match.game_length, 2) if match.game_length is not None else None,
        "game_length_formatted": format_game_length(match.game_length),
        "participants": participants,
    }