//
//  RecentMatchesResponse.swift
//  MrTFT
//
//  Created by Jeff Jimenez on 3/11/26.
//

import Foundation

struct RecentMatchesResponse: Decodable {
    let player: String
    let matches: [RecentMatch]
}

struct RecentMatch: Decodable, Identifiable {
    let matchID: String
    let placement: Int
    let level: Int?
    let goldLeft: Int?
    let lastRound: Int?
    let totalDamage: Int?
    let patch: String?
    let gameLengthSeconds: Double?
    let gameLengthFormatted: String?
    let gameDate: String?
    let gameDatetime: String?

    var id: String { matchID }

    enum CodingKeys: String, CodingKey {
        case matchID = "match_id"
        case placement
        case level
        case goldLeft = "gold_left"
        case lastRound = "last_round"
        case totalDamage = "total_damage"
        case patch
        case gameLengthSeconds = "game_length_seconds"
        case gameLengthFormatted = "game_length_formatted"
        case gameDate = "game_date"
        case gameDatetime = "game_datetime"
    }
}
