//
//  MatchDetailView.swift
//  MrTFT
//
//  Created by Jeff Jimenez on 3/11/26.
//

import SwiftUI

struct MatchDetailView: View {
    let matchID: String

    @StateObject private var viewModel = MatchDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Match Detail")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(matchID)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                if viewModel.isLoading {
                    ProgressView("Loading match...")
                } else if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                } else if let match = viewModel.matchDetail {
                    VStack(spacing: 12) {
                        detailRow(title: "Patch", value: match.patch ?? "-")
                        detailRow(title: "Date", value: match.gameDate ?? "-")
                        detailRow(title: "Length", value: match.gameLengthFormatted ?? "-")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Participants")
                            .font(.title2)
                            .fontWeight(.semibold)

                        ForEach(match.participants) { participant in
                            VStack(spacing: 8) {
                                HStack {
                                    Text(displayName(for: participant))
                                        .fontWeight(.semibold)

                                    Spacer()

                                    Text(placementLabel(participant.placement))
                                        .fontWeight(.bold)
                                }

                                HStack {
                                    Text("Level: \(participant.level ?? 0)")
                                    Spacer()
                                    Text("Damage: \(participant.totalDamage ?? 0)")
                                }
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Match")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadMatchDetail(matchID: matchID)
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
        }
    }

    private func displayName(for participant: MatchParticipant) -> String {
        if let gameName = participant.gameName, let tagLine = participant.tagLine {
            return "\(gameName)#\(tagLine)"
        } else {
            return "Unknown Player"
        }
    }

    private func placementLabel(_ placement: Int) -> String {
        switch placement {
        case 1:
            return "1st"
        case 2:
            return "2nd"
        case 3:
            return "3rd"
        default:
            return "\(placement)th"
        }
    }
}

#Preview {
    NavigationStack {
        MatchDetailView(matchID: "NA1_5508243000")
    }
}
