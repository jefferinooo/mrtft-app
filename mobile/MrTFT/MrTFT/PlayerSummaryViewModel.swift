import Foundation
import Combine

@MainActor
final class PlayerSummaryViewModel: ObservableObject {
    @Published var summary: PlayerSummary?
    @Published var recentMatches: [RecentMatch] = []
    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var errorMessage: String = ""

    private var refreshTask: Task<Void, Never>?

    func loadProfile(gameName: String, tagLine: String) async {
        isLoading = true
        errorMessage = ""

        await fetchProfileData(gameName: gameName, tagLine: tagLine)

        isLoading = false
    }

    func startRefresh(gameName: String, tagLine: String) {
        guard !isRefreshing else { return }

        refreshTask?.cancel()

        refreshTask = Task {
            await refreshProfile(gameName: gameName, tagLine: tagLine)
        }
    }

    private func refreshProfile(gameName: String, tagLine: String) async {
        isRefreshing = true
        errorMessage = ""

        do {
            try await APIService.shared.ingestMatches(
                gameName: gameName,
                tagLine: tagLine
            )
        } catch {
            print("Ingest failed during pull-to-refresh:", error)
            print("Localized:", error.localizedDescription)

            if isCancelledError(error) {
                print("Ingest was cancelled, but not showing UI error.")
                isRefreshing = false
                return
            }

            errorMessage = "Failed to refresh matches."
            isRefreshing = false
            return
        }

        await fetchProfileData(gameName: gameName, tagLine: tagLine)

        isRefreshing = false
    }

    private func fetchProfileData(gameName: String, tagLine: String) async {
        do {
            async let summaryRequest = APIService.shared.fetchPlayerSummary(
                gameName: gameName,
                tagLine: tagLine
            )

            async let recentMatchesRequest = APIService.shared.fetchRecentMatches(
                gameName: gameName,
                tagLine: tagLine
            )

            let (summaryResult, recentMatchesResult) = try await (
                summaryRequest,
                recentMatchesRequest
            )

            summary = summaryResult
            recentMatches = recentMatchesResult.matches
        } catch {
            print("Profile data fetch failed:", error)
            print("Localized:", error.localizedDescription)

            if isCancelledError(error) {
                return
            }

            errorMessage = "Failed to load player profile."
        }
    }

    private func isCancelledError(_ error: Error) -> Bool {
        let nsError = error as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled
    }
}
