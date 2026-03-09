from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.db.models.match import Match
from app.db.models.participant import Participant
from app.db.models.player import Player
from app.core.utils import format_game_length

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

    participants = []
    for participant, player in rows:
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
        "game_datetime": match.game_datetime.isoformat() if match.game_datetime else None,
        "game_length_seconds": round(match.game_length, 2) if match.game_length is not None else None,
        "game_length_formatted": format_game_length(match.game_length),
        "participants": participants,
    }