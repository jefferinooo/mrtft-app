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
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""

    func loadSummary(gameName: String, tagLine: String) async {
        isLoading = true
        errorMessage = ""

        do {
            summary = try await APIService.shared.fetchPlayerSummary(
                gameName: gameName,
                tagLine: tagLine
            )
        } catch {
            errorMessage = "Failed to load player summary."
        }

        isLoading = false
    }
}

