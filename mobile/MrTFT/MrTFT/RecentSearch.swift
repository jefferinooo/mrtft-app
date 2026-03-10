//
//  RecentSearch.swift
//  MrTFT
//
//  Created by Jeff Jimenez on 3/10/26.
//

import Foundation

struct RecentSearch: Codable, Identifiable, Equatable {
    let id: UUID
    let gameName: String
    let tagLine: String

    init(id: UUID = UUID(), gameName: String, tagLine: String) {
        self.id = id
        self.gameName = gameName
        self.tagLine = tagLine
    }
}
