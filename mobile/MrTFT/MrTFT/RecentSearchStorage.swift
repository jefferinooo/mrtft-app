//
//  RecentSearchStorage.swift
//  MrTFT
//
//  Created by Jeff Jimenez on 3/10/26.
//

import Foundation

final class RecentSearchStorage {
    static let shared = RecentSearchStorage()

    private let key = "recent_searches"

    private init() {}

    func loadRecentSearches() -> [RecentSearch] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }

        do {
            return try JSONDecoder().decode([RecentSearch].self, from: data)
        } catch {
            return []
        }
    }

    func saveRecentSearches(_ searches: [RecentSearch]) {
        do {
            let data = try JSONEncoder().encode(searches)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to save recent searches: \(error)")
        }
    }

    func addRecentSearch(gameName: String, tagLine: String) {
        var searches = loadRecentSearches()

        let normalizedGameName = gameName.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedTagLine = tagLine.trimmingCharacters(in: .whitespacesAndNewlines)

        let newSearch = RecentSearch(gameName: normalizedGameName, tagLine: normalizedTagLine)

        searches.removeAll {
            $0.gameName.lowercased() == normalizedGameName.lowercased() &&
            $0.tagLine.lowercased() == normalizedTagLine.lowercased()
        }

        searches.insert(newSearch, at: 0)

        if searches.count > 5 {
            searches = Array(searches.prefix(5))
        }

        saveRecentSearches(searches)
    }
}
