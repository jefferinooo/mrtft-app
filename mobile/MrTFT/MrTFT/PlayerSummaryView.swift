import SwiftUI

struct PlayerSummaryView: View {
    let gameName: String
    let tagLine: String

    @StateObject private var viewModel = PlayerSummaryViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Player Summary")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("\(gameName)#\(tagLine)")
                .font(.title2)

            if viewModel.isLoading {
                ProgressView("Loading summary...")
            } else if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            } else if let summary = viewModel.summary {
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

            Spacer()
        }
        .padding()
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadSummary(gameName: gameName, tagLine: tagLine)
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
}

#Preview {
    NavigationStack {
        PlayerSummaryView(gameName: "Taurus Gang", tagLine: "EPIC")
    }
}
