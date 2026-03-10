//
//  ContentView.swift
//  MrTFT
//
//  Created by Jeff Jimenez on 3/10/26.
//

import SwiftUI

struct ContentView: View {

    @State private var gameName: String = ""
    @State private var tagLine: String = ""

    @State private var statusMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var recentSearches: [RecentSearch] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                Text("MrTFT")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                HStack {
                    TextField("Game Name", text: $gameName)
                        .textFieldStyle(.roundedBorder)

                    Text("#")

                    TextField("Tag Line", text: $tagLine)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }

                Button("Refresh Matches") {
                    Task {
                        await refreshMatches()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(gameName.isEmpty || tagLine.isEmpty || isLoading)

                NavigationLink(
                    destination: PlayerSummaryView(
                        gameName: gameName,
                        tagLine: tagLine
                    )
                ) {
                    Text("View Profile")
                }
                .simultaneousGesture(TapGesture().onEnded {
                    saveCurrentSearch()
                })
                .disabled(gameName.isEmpty || tagLine.isEmpty || isLoading)

                if isLoading {
                    ProgressView()
                }

                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }

                if !recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Searches")
                            .font(.headline)

                        ForEach(recentSearches) { search in
                            NavigationLink(
                                destination: PlayerSummaryView(
                                    gameName: search.gameName,
                                    tagLine: search.tagLine
                                )
                            ) {
                                HStack {
                                    Text("\(search.gameName)#\(search.tagLine)")
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
            }
            .padding()
            .onAppear {
                recentSearches = RecentSearchStorage.shared.loadRecentSearches()
            }
        }
    }

    private func refreshMatches() async {
        isLoading = true
        statusMessage = "Refreshing matches..."

        do {
            try await APIService.shared.ingestMatches(
                gameName: gameName,
                tagLine: tagLine
            )
            saveCurrentSearch()
            statusMessage = "Matches refreshed successfully."
        } catch {
            statusMessage = "Failed to refresh matches."
        }

        isLoading = false
    }

    private func saveCurrentSearch() {
        guard !gameName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !tagLine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        RecentSearchStorage.shared.addRecentSearch(
            gameName: gameName,
            tagLine: tagLine
        )

        recentSearches = RecentSearchStorage.shared.loadRecentSearches()
    }
}

#Preview {
    ContentView()
}
