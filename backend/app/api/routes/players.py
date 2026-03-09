from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func, case

from app.api.deps import get_db
from app.db.models.player import Player
from app.db.models.participant import Participant
from app.db.models.match import Match

router = APIRouter(prefix="/players", tags=["players"])

def format_game_length(seconds: float | None) -> str | None:
    if seconds is None:
        return None

    total_seconds = int(seconds)
    minutes = total_seconds // 60
    remaining_seconds = total_seconds % 60
    return f"{minutes}:{remaining_seconds:02d}"

@router.get("/{game_name}/{tag_line}/summary")
def get_player_summary(game_name: str, tag_line: str, db: Session = Depends(get_db)):
    # 1) Find the player in your database
    player = (
        db.query(Player)
        .filter(Player.game_name == game_name, Player.tag_line == tag_line)
        .one_or_none()
    )

    if player is None:
        raise HTTPException(status_code=404, detail="Player not found in database. Ingest them first.")

    # 2) Compute aggregate stats from participants table
    result = (
        db.query(
            func.count(Participant.id).label("matches"),
            func.avg(Participant.placement).label("avg_placement"),
            func.avg(
                case((Participant.placement <= 4, 1), else_=0)
            ).label("top4_rate"),
            func.avg(
                case((Participant.placement == 1, 1), else_=0)
            ).label("win_rate"),
        )
        .filter(Participant.player_id == player.id)
        .one()
    )

    matches = result.matches or 0

    return {
        "player": f"{player.game_name}#{player.tag_line}",
        "puuid": player.puuid,
        "matches": matches,
        "avg_placement": round(float(result.avg_placement), 2) if result.avg_placement is not None else None,
        "top4_rate": round(float(result.top4_rate), 3) if result.top4_rate is not None else None,
        "win_rate": round(float(result.win_rate), 3) if result.win_rate is not None else None,
    }

@router.get("/{game_name}/{tag_line}/recent")
def get_recent_matches(game_name: str, tag_line: str, db: Session = Depends(get_db)):
    player = (
        db.query(Player)
        .filter(Player.game_name == game_name, Player.tag_line == tag_line)
        .one_or_none()
    )

    if player is None:
        raise HTTPException(status_code=404, detail="Player not found in database. Ingest them first.")
    
    rows = (
        db.query(Participant, Match)
        .join(Match, Participant.match_id == Match.id)
        .filter(Participant.player_id == player.id)
        .order_by(Match.game_datetime.desc(), Match.id.desc())
        .limit(20)
        .all()
    )

    matches = []

    for participant, match in rows:
        matches.append({
            "match_id": match.match_id,
            "placement": participant.placement,
            "level": participant.level,
            "gold_left": participant.gold_left,
            "last_round": participant.last_round,
            "total_damage": participant.total_damage,
            "patch": match.patch,
            "game_length_seconds": round(match.game_length, 2) if match.game_length is not None else None,
            "game_length_formatted": format_game_length(match.game_length),
            "game_datetime": match.game_datetime.isoformat() if match.game_datetime else None,
        })

    return {
        "player": f"{player.game_name}#{player.tag_line}",
        "matches": matches,
    }

@router.get("/{game_name}/{tag_line}/placements")
def get_player_placements(game_name: str, tag_line: str, db: Session = Depends(get_db)):
    player = (
        db.query(Player)
        .filter(Player.game_name == game_name, Player.tag_line == tag_line)
        .one_or_none()
    )

    if player is None:
        raise HTTPException(status_code=404, detail="Player not found in database. Ingest them first.")

    '''
    .order_by is asc instead of desc because we want oldest to newest for graphing later
    '''
    
    rows = (
        db.query(Participant, Match)
        .join(Match, Participant.match_id == Match.id)
        .filter(Participant.player_id == player.id)
        .order_by(Match.game_datetime.asc(), Match.id.asc())
        .all()
    )

    placements = []
    for idx, (participant, match) in enumerate(rows, start=1):
        placements.append({
            "game_number": idx,
            "match_id": match.match_id,
            "placement": participant.placement,
            "patch": match.patch,
        })

    return {
        "player": f"{player.game_name}#{player.tag_line}",
        "placements": placements,
    }

@router.get("/{game_name}/{tag_line}/stats-by-patch")
def get_stats_by_patch(game_name: str, tag_line: str, db: Session = Depends(get_db)):
    player = (
        db.query(Player)
        .filter(Player.game_name == game_name, Player.tag_line == tag_line)
        .one_or_none()
    )

    if player is None:
        raise HTTPException(status_code=404, detail="Player not found in database. Ingest them first.")

    rows = (
        db.query(
            Match.patch.label("patch"),
            func.count(Participant.id).label("matches"),
            func.avg(Participant.placement).label("avg_placement"),
            func.avg(case((Participant.placement <= 4, 1), else_=0)).label("top4_rate"),
            func.avg(case((Participant.placement == 1, 1), else_=0)).label("win_rate"),
        )
        .join(Match, Participant.match_id == Match.id)
        .filter(Participant.player_id == player.id)
        .group_by(Match.patch)
        .order_by(Match.patch.asc())
        .all()
    )

    patch_stats = []
    for row in rows:
        patch_stats.append({
            "patch": row.patch,
            "matches": row.matches,
            "avg_placement": round(float(row.avg_placement), 2) if row.avg_placement is not None else None,
            "top4_rate": round(float(row.top4_rate), 3) if row.top4_rate is not None else None,
            "win_rate": round(float(row.win_rate), 3) if row.win_rate is not None else None,
        })

    return {
        "player": f"{player.game_name}#{player.tag_line}",
        "patch_stats": patch_stats,
    }


@router.get("/{game_name}/{tag_line}/placement-distribution")
def get_placement_distribution(game_name: str, tag_line: str, db: Session = Depends(get_db)):
    player = (
        db.query(Player)
        .filter(Player.game_name == game_name, Player.tag_line == tag_line)
        .one_or_none()
    )

    if player is None:
        raise HTTPException(status_code=404, detail="Player not found in database. Ingest them first.")

    rows = (
        db.query(
            Participant.placement,
            func.count(Participant.id).label("count"),
        )
        .filter(Participant.player_id == player.id)
        .group_by(Participant.placement)
        .order_by(Participant.placement.asc())
        .all()
    )

    distribution = {str(i): 0 for i in range(1, 9)}
    for row in rows:
        distribution[str(row.placement)] = row.count

    return {
        "player": f"{player.game_name}#{player.tag_line}",
        "distribution": distribution,
    }