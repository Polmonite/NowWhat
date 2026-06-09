import Foundation

/// Checks the latest GitHub release against the running version.
@MainActor
final class UpdateChecker: ObservableObject {
    enum Status: Equatable {
        case idle
        case checking
        case upToDate
        case updateAvailable(version: String, url: URL)
        case failed(String)
    }

    @Published var status: Status = .idle

    /// owner/repo on GitHub.
    private let repo = "Polmonite/NowWhat"

    var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    }

    func check() {
        status = .checking
        Task {
            do {
                let latest = try await fetchLatest()
                if Self.isNewer(latest.version, than: currentVersion) {
                    status = .updateAvailable(version: latest.version, url: latest.url)
                } else {
                    status = .upToDate
                }
            } catch {
                let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                status = .failed(message)
            }
        }
    }

    private struct Release: Decodable {
        let tag_name: String
        let html_url: String
    }

    private func fetchLatest() async throws -> (version: String, url: URL) {
        let endpoint = URL(string: "https://api.github.com/repos/\(repo)/releases/latest")!
        var request = URLRequest(url: endpoint)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("NowWhat", forHTTPHeaderField: "User-Agent")
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw UpdateError.network }
        if http.statusCode == 404 { throw UpdateError.noReleases }
        guard http.statusCode == 200 else { throw UpdateError.server(http.statusCode) }

        let release = try JSONDecoder().decode(Release.self, from: data)
        let tag = release.tag_name
        let version = tag.hasPrefix("v") ? String(tag.dropFirst()) : tag
        guard let pageURL = URL(string: release.html_url) else { throw UpdateError.network }
        return (version, pageURL)
    }

    /// Numeric component comparison, e.g. "1.10" > "1.9".
    static func isNewer(_ candidate: String, than current: String) -> Bool {
        let lhs = candidate.split(separator: ".").map { Int($0) ?? 0 }
        let rhs = current.split(separator: ".").map { Int($0) ?? 0 }
        for index in 0..<max(lhs.count, rhs.count) {
            let l = index < lhs.count ? lhs[index] : 0
            let r = index < rhs.count ? rhs[index] : 0
            if l != r { return l > r }
        }
        return false
    }

    private enum UpdateError: LocalizedError {
        case network
        case noReleases
        case server(Int)

        var errorDescription: String? {
            switch self {
            case .network: return "Could not reach GitHub."
            case .noReleases: return "No releases published yet."
            case .server(let code): return "GitHub returned status \(code)."
            }
        }
    }
}
