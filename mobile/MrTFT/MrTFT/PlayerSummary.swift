//
//  PlayerSummary.swift
//  MrTFT
//
//  Created by Jeff Jimenez on 3/10/26.
//

import Foundation

struct PlayerSummary: Decodable {
    let player: String
    let puuid: String
    let matches: Int
    let avgPlacement: Double?
    let top4Rate: Double?
    let winRate: Double?

    enum CodingKeys: String, CodingKey {
        case player
        case puuid
        case matches
        case avgPlacement = "avg_placement"
        case top4Rate = "top4_rate"
        case winRate = "win_rate"
    }
}
