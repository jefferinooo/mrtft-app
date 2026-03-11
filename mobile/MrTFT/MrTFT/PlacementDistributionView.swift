//
//  PlacementDistributionView.swift
//  MrTFT
//
//  Created by Jeff Jimenez on 3/11/26.
//

import SwiftUI
import Charts

struct PlacementDistributionView: View {
    let gameName: String
    let tagLine: String

    @StateObject private var viewModel = PlacementDistributionViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Placement Distribution")
                .font(.title2)
                .fontWeight(.semibold)

            if viewModel.isLoading {
                ProgressView("Loading distribution...")
            } else if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
            } else if viewModel.bars.isEmpty {
                Text("No placement data available.")
                    .foregroundColor(.gray)
            } else {
                Chart(viewModel.bars) { bar in
                    BarMark(
                        x: .value("Placement", bar.placement),
                        y: .value("Count", bar.count)
                    )
                    .annotation(position: .top) {
                        Text("\(bar.count)")
                            .font(.caption)
                    }
                }
                .frame(height: 240)
                .chartXAxisLabel("Placement")
                .chartYAxisLabel("Frequency")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .task {
            await viewModel.loadDistribution(gameName: gameName, tagLine: tagLine)
        }
    }
}

#Preview {
    PlacementDistributionView(gameName: "Taurus Gang", tagLine: "EPIC")
}
