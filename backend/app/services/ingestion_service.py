from sqlalchemy.orm import Session
from app.services.riot_client import RiotClient
from app.db.models.player import Player
from app.db.models.match import Match
from app.db.models.participant import Participant


class IngestionService:
    def __init__(self) -> None:
        self.riot = RiotClient()

    def ingest_recent_matches(self, db: Session, game_name: str, tag_line: str, count: int = 20) -> dict:
        # 1) Riot ID -> PUUID
        account = self.riot.get_account_by_riot_id(game_name, tag_line)
        puuid = account["puuid"]

        # 2) Ensure requesting player exists (or create)
        player = db.query(Player).filter(Player.puuid == puuid).one_or_none()
        if player is None:
            player = Player(
                puuid=puuid,
                game_name=account.get("gameName"),
                tag_line=account.get("tagLine"),
                region=None,
            )
            db.add(player)
            db.commit()
            db.refresh(player)
        else:
            # Optional: keep name/tag in sync if they were missing before
            if not player.game_name:
                player.game_name = account.get("gameName")
            if not player.tag_line:
                player.tag_line = account.get("tagLine")
            db.commit()

        # 3) PUUID -> match ids
        match_ids = self.riot.get_match_ids_by_puuid(puuid, count=count)

        ingested = 0
        skipped = 0

        for match_id in match_ids:
            # Skip duplicates (match already stored)
            if db.query(Match).filter(Match.match_id == match_id).one_or_none():
                skipped += 1
                continue

            # 4) Fetch match JSON
            match_json = self.riot.get_match_detail(match_id)

            info = match_json.get("info", {})
            metadata = match_json.get("metadata", {})

            # Create match row
            match = Match(
                match_id=metadata.get("match_id", match_id),
                patch=info.get("game_version"),
                queue_id=info.get("queue_id"),
                game_datetime=None,  # we’ll convert later
                game_length=info.get("game_length"),
            )
            db.add(match)
            db.commit()
            db.refresh(match)

            participants = info.get("participants", [])
            if not participants:
                # weird edge case; don't count as ingested
                skipped += 1
                continue

            # 5) Store ALL participants (typically 8)
            for p in participants:
                p_puuid = p.get("puuid")
                if not p_puuid:
                    continue

                # Ensure player row exists for this participant
                p_player = db.query(Player).filter(Player.puuid == p_puuid).one_or_none()
                if p_player is None:
                    p_player = Player(
                        puuid=p_puuid,
                        game_name=None,
                        tag_line=None,
                        region=None,
                    )
                    db.add(p_player)
                    db.flush()  # assigns p_player.id without committing

                # If you added the unique constraint (match_id, player_id),
                # this is extra-safe but optional:
                existing_participant = (
                    db.query(Participant)
                    .filter(Participant.match_id == match.id, Participant.player_id == p_player.id)
                    .one_or_none()
                )
                if existing_participant:
                    continue

                db.add(
                    Participant(
                        match_id=match.id,
                        player_id=p_player.id,
                        placement=p.get("placement"),
                        level=p.get("level"),
                        gold_left=p.get("gold_left"),
                        last_round=p.get("last_round"),
                        total_damage=p.get("total_damage_to_players"),
                    )
                )

            # Commit once per match (better performance + cleaner)
            db.commit()
            ingested += 1

        return {
            "player": f"{game_name}#{tag_line}",
            "puuid": puuid,
            "requested": count,
            "ingested": ingested,
            "skipped": skipped,
        }