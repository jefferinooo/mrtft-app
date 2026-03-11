import SwiftUI

struct PlayerSummaryView: View {
    let gameName: String
    let tagLine: String

    @StateObject private var viewModel = PlayerSummaryViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                Text("\(gameName)#\(tagLine)")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if viewModel.isLoading {
                    ProgressView("Loading profile...")
                } else if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                } else {
                    if let summary = viewModel.summary {
                        VStack(spacing: 16) {
                            summaryRow(title: "Matches", value: "\(summary.matches)")
                            summaryRow(
                                title: "Avg Placement",
                                value: summary.avgPlacement != nil ? String(format: "%.2f", summary.avgPlacement!) : "-"
                            )
                            summaryRow(
                                title: "Top 4 Rate",
                                value: summary.top4Rate != nil ? "\(Int(summary.top4Rate! * 100))%" : "-"
                            )
                            summaryRow(
                                title: "Win Rate",
                                value: summary.winRate != nil ? "\(Int(summary.winRate! * 100))%" : "-"
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Matches")
                            .font(.title2)
                            .fontWeight(.semibold)

                        if viewModel.recentMatches.isEmpty {
                            Text("No recent matches found.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(viewModel.recentMatches) { match in
                                NavigationLink(
                                    destination: MatchDetailView(matchID: match.matchID)
                                ) {
                                    VStack(spacing: 8) {
                                        HStack {
                                            Text(placementLabel(match.placement))
                                                .fontWeight(.bold)

                                            Spacer()

                                            Text(match.patch ?? "-")
                                                .foregroundColor(.secondary)
                                        }

                                        HStack {
                                            Text(match.gameDate ?? "")
                                                .foregroundColor(.secondary)

                                            Spacer()

                                            Text(match.gameLengthFormatted ?? "-")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadProfile(gameName: gameName, tagLine: tagLine)
        }
    }

    private func summaryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)

            Spacer()

            Text(value)
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
        PlayerSummaryView(gameName: "Taurus Gang", tagLine: "EPIC")
    }
}
