//
//  PlacementDistributionResponse.swift
//  MrTFT
//
//  Created by Jeff Jimenez on 3/11/26.
//

import Foundation

struct PlacementDistributionResponse: Decodable {
    let player: String
    let distribution: [String: Int]
}

struct PlacementDistributionBar: Identifiable {
    let placement: String
    let count: Int

    var id: String { placement }
}
