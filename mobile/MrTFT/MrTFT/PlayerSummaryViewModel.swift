//
//  PlayerSummaryViewModel.swift
//  MrTFT
//
//  Created by Jeff Jimenez on 3/10/26.
//

import Foundation
import Combine

@MainActor
final class PlayerSummaryViewModel: ObservableObject {
    @Published var summary: PlayerSummary?
    @Published var recentMatches: [RecentMatch] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""

    func loadProfile(gameName: String, tagLine: String) async {
        isLoading = true
        errorMessage = ""

        do {
            // refresh / ingest latest matches first
            try await APIService.shared.ingestMatches(
                gameName: gameName,
                tagLine: tagLine
            )

            // fetch updated profile data
            async let summaryRequest = APIService.shared.fetchPlayerSummary(
                gameName: gameName,
                tagLine: tagLine
            )

            async let recentMatchesRequest = APIService.shared.fetchRecentMatches(
                gameName: gameName,
                tagLine: tagLine
            )

            let (summaryResult, recentMatchesResult) = try await (summaryRequest, recentMatchesRequest)

            summary = summaryResult
            recentMatches = recentMatchesResult.matches
        } catch {
            errorMessage = "Failed to load player profile."
        }

        isLoading = false
    }
}
