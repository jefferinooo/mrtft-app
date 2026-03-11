//
//  PlacementDistributionViewModel.swift
//  MrTFT
//
//  Created by Jeff Jimenez on 3/11/26.
//

import Foundation
import Combine

@MainActor
final class PlacementDistributionViewModel: ObservableObject {
    @Published var bars: [PlacementDistributionBar] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""

    func loadDistribution(gameName: String, tagLine: String) async {
        isLoading = true
        errorMessage = ""

        do {
            let response = try await APIService.shared.fetchPlacementDistribution(
                gameName: gameName,
                tagLine: tagLine
            )

            let orderedPlacements = ["1", "2", "3", "4", "5", "6", "7", "8"]

            bars = orderedPlacements.map { placement in
                PlacementDistributionBar(
                    placement: placementLabel(for: placement),
                    count: response.distribution[placement] ?? 0
                )
            }
        } catch {
            errorMessage = "Failed to load placement distribution."
        }

        isLoading = false
    }

    private func placementLabel(for placement: String) -> String {
        switch placement {
        case "1": return "1st"
        case "2": return "2nd"
        case "3": return "3rd"
        default: return "\(placement)th"
        }
    }
}
