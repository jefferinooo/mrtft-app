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
                    .foregroundStyle(color(for: bar.placement))
                    .annotation(position: .top) {
                        Text("\(bar.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(color(for: bar.placement))
                    }
                }
                .frame(height: 240)
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel() {
                            if let placement = value.as(String.self) {
                                Text(placement)
                                    .foregroundColor(color(for: placement))
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .task {
            await viewModel.loadDistribution(gameName: gameName, tagLine: tagLine)
        }
    }

    private func color(for placement: String) -> Color {
        switch placement {
        case "1st":
            return .yellow
        case "2nd":
            return .pink
        case "3rd":
            return .blue
        case "4th":
            return .green
        case "5th":
            return .gray
        case "6th":
            return Color(.systemGray3)
        case "7th":
            return Color(.systemGray)
        case "8th":
            return Color(.lightGray)
        default:
            return .blue
        }
    }
}

#Preview {
    PlacementDistributionView(gameName: "Taurus Gang", tagLine: "EPIC")
}
