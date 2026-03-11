//
//  MatchDetailResponse.swift
//  MrTFT
//
//  Created by Jeff Jimenez on 3/11/26.
//

import Foundation

struct MatchDetailResponse: Decodable {
    let matchID: String
    let patch: String?
    let queueID: Int?
    let gameDate: String?
    let gameDatetime: String?
    let gameLengthSeconds: Double?
    let gameLengthFormatted: String?
    let participants: [MatchParticipant]

    enum CodingKeys: String, CodingKey {
        case matchID = "match_id"
        case patch
        case queueID = "queue_id"
        case gameDate = "game_date"
        case gameDatetime = "game_datetime"
        case gameLengthSeconds = "game_length_seconds"
        case gameLengthFormatted = "game_length_formatted"
        case participants
    }
}

struct MatchParticipant: Decodable, Identifiable {
    let playerID: Int
    let puuid: String
    let gameName: String?
    let tagLine: String?
    let placement: Int
    let level: Int?
    let goldLeft: Int?
    let lastRound: Int?
    let totalDamage: Int?

    var id: Int { playerID }

    enum CodingKeys: String, CodingKey {
        case playerID = "player_id"
        case puuid
        case gameName = "game_name"
        case tagLine = "tag_line"
        case placement
        case level
        case goldLeft = "gold_left"
        case lastRound = "last_round"
        case totalDamage = "total_damage"
    }
}
