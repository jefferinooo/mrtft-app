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

        # 2) Ensure player exists (or create)
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

        # 3) PUUID -> match ids
        match_ids = self.riot.get_match_ids_by_puuid(puuid, count=count)

        ingested = 0
        skipped = 0

        for match_id in match_ids:
            # Skip duplicates
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

            # Find this player's participant block
            me = None
            for p in info.get("participants", []):
                if p.get("puuid") == puuid:
                    me = p
                    break

            if me is None:
                skipped += 1
                continue

            # Create participant row (your player's stats for that match)
            participant = Participant(
                match_id=match.id,
                player_id=player.id,
                placement=me.get("placement"),
                level=me.get("level"),
                gold_left=me.get("gold_left"),
                last_round=me.get("last_round"),
                total_damage=me.get("total_damage_to_players"),
            )
            db.add(participant)
            db.commit()

            ingested += 1

        return {
            "player": f"{game_name}#{tag_line}",
            "puuid": puuid,
            "requested": count,
            "ingested": ingested,
            "skipped": skipped,
        }