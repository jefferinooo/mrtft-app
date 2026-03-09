def format_game_length(seconds: float | None) -> str | None:
    """
    convert game length from seconds to MM:SS format.
    ex: 2209.65 -> "36:49"
    """
    if seconds is None:
        return None

    total_seconds = int(seconds)
    minutes = total_seconds // 60
    remaining_seconds = total_seconds % 60

    return f"{minutes}:{remaining_seconds:02d}"

def format_game_date(dt) -> str | None:
    """
    converts datetime into readable date.
    ex: 2026-03-08 -> 'Mar 9'
    """
    if dt is None:
        return None

    return dt.strftime("%b %-d")