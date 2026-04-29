import Foundation

final class APIService {
    static let shared = APIService()

    private init() {}

    private let baseURL = "http://mrtft-alb-2067101800.us-west-2.elb.amazonaws.com"

    func ingestMatches(gameName: String, tagLine: String, count: Int = 20) async throws {
        let encodedGameName = gameName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? gameName
        let encodedTagLine = tagLine.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? tagLine

        let urlString = "\(baseURL)/ingest/\(encodedGameName)/\(encodedTagLine)?count=\(count)"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
    }

    func fetchPlayerSummary(gameName: String, tagLine: String) async throws -> PlayerSummary {
        let encodedGameName = gameName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? gameName
        let encodedTagLine = tagLine.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? tagLine

        let urlString = "\(baseURL)/players/\(encodedGameName)/\(encodedTagLine)/summary"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(PlayerSummary.self, from: data)
    }
    
    func fetchRecentMatches(gameName: String, tagLine: String) async throws -> RecentMatchesResponse {
        let encodedGameName = gameName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? gameName
        let encodedTagLine = tagLine.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? tagLine

        let urlString = "\(baseURL)/players/\(encodedGameName)/\(encodedTagLine)/recent"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(RecentMatchesResponse.self, from: data)
    }
    
    func fetchMatchDetail(matchID: String) async throws -> MatchDetailResponse {
        let encodedMatchID = matchID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? matchID
        let urlString = "\(baseURL)/matches/\(encodedMatchID)"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(MatchDetailResponse.self, from: data)
    }
    
    func fetchPlacementDistribution(gameName: String, tagLine: String) async throws -> PlacementDistributionResponse {
        let encodedGameName = gameName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? gameName
        let encodedTagLine = tagLine.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? tagLine

        let urlString = "\(baseURL)/players/\(encodedGameName)/\(encodedTagLine)/placement-distribution"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(PlacementDistributionResponse.self, from: data)
    }
    
    func ingestPlayer(gameName: String, tagLine: String) async throws {
        let encodedGameName = gameName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? gameName
        let encodedTagLine = tagLine.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? tagLine

        let urlString = "\(baseURL)/ingest/\(encodedGameName)/\(encodedTagLine)"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
    }
}
