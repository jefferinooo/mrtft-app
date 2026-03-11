//
//  MatchDetailViewModel.swift
//  MrTFT
//
//  Created by Jeff Jimenez on 3/11/26.
//

import Foundation
import Combine

@MainActor
final class MatchDetailViewModel: ObservableObject {
    @Published var matchDetail: MatchDetailResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""

    func loadMatchDetail(matchID: String) async {
        isLoading = true
        errorMessage = ""

        do {
            matchDetail = try await APIService.shared.fetchMatchDetail(matchID: matchID)
        } catch {
            errorMessage = "Failed to load match detail."
        }

        isLoading = false
    }
}
