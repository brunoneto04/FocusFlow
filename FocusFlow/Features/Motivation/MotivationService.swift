// FocusFlow/Features/Motivation/MotivationService.swift

import Foundation

/// Service responsible for fetching motivational quotes from the ZenQuotes API
actor MotivationService {

    // MARK: - Properties

    /// Shared singleton instance
    static let shared = MotivationService()

    /// Base URL for the ZenQuotes API
    private let baseURL = "https://zenquotes.io/api"

    /// URLSession configured for secure networking
    private let session: URLSession

    /// Simple in-memory cache for offline support
    private var cachedQuotes: [MotivationQuote] = []
    private var lastFetchTime: Date?
    private let cacheExpirationSeconds: TimeInterval = 300 // 5 minutes

    // MARK: - Initialization

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.waitsForConnectivity = true
        // Disable caching to always get fresh quotes
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = nil
        self.session = URLSession(configuration: config)
    }

    // MARK: - Public Methods

    /// Fetches a random motivational quote from ZenQuotes
    /// - Parameter ignoreCache: If true, bypasses the cache and forces a network request
    /// - Returns: A MotivationQuote object
    /// - Throws: MotivationError if the request fails
    func fetchRandomQuote(ignoreCache: Bool = false) async throws -> MotivationQuote {
        // Check cache first (only if not ignoring cache)
        if !ignoreCache,
           let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < cacheExpirationSeconds,
           let randomCached = cachedQuotes.randomElement() {
            return randomCached
        }

        // Add timestamp to prevent caching at API level
        let timestamp = Date().timeIntervalSince1970
        let url = URL(string: "\(baseURL)/random?\(timestamp)")!

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw MotivationError.networkError("Invalid response type")
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw MotivationError.networkError("Server returned status code \(httpResponse.statusCode)")
            }

            let decoder = JSONDecoder()
            let quotes = try decoder.decode([MotivationQuote].self, from: data)

            guard let quote = quotes.first else {
                throw MotivationError.decodingError("No quotes returned")
            }

            // Add to cache
            if !cachedQuotes.contains(where: { $0.id == quote.id }) {
                cachedQuotes.append(quote)
            }
            lastFetchTime = Date()

            // Keep cache size manageable (max 50 quotes)
            if cachedQuotes.count > 50 {
                cachedQuotes.removeFirst(cachedQuotes.count - 50)
            }

            return quote

        } catch let error as DecodingError {
            // If network fails and we have cache, return random cached quote
            if !cachedQuotes.isEmpty, let fallbackQuote = cachedQuotes.randomElement() {
                return fallbackQuote
            }
            throw MotivationError.decodingError(error.localizedDescription)
        } catch let error as URLError {
            // If network fails and we have cache, return random cached quote
            if !cachedQuotes.isEmpty, let fallbackQuote = cachedQuotes.randomElement() {
                return fallbackQuote
            }
            
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw MotivationError.networkError("No internet connection. Please check your network.")
            case .timedOut:
                throw MotivationError.networkError("Request timed out. Please try again.")
            case .secureConnectionFailed:
                throw MotivationError.networkError("Secure connection failed. Please check your network security settings.")
            default:
                throw MotivationError.networkError("Network error: \(error.localizedDescription)")
            }
        } catch {
            // If network fails and we have cache, return random cached quote
            if !cachedQuotes.isEmpty, let fallbackQuote = cachedQuotes.randomElement() {
                return fallbackQuote
            }
            throw MotivationError.unknownError(error.localizedDescription)
        }
    }

    /// Fetches today's quote from ZenQuotes
    /// - Returns: A MotivationQuote object
    func fetchTodayQuote() async throws -> MotivationQuote {
        let url = URL(string: "\(baseURL)/today")!

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw MotivationError.networkError("Failed to fetch today's quote")
            }

            let decoder = JSONDecoder()
            let quotes = try decoder.decode([MotivationQuote].self, from: data)

            guard let quote = quotes.first else {
                throw MotivationError.decodingError("No quote returned")
            }

            return quote

        } catch let error as DecodingError {
            throw MotivationError.decodingError(error.localizedDescription)
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw MotivationError.networkError("No internet connection")
            case .timedOut:
                throw MotivationError.networkError("Request timed out")
            case .secureConnectionFailed:
                throw MotivationError.networkError("Secure connection failed")
            default:
                throw MotivationError.networkError(error.localizedDescription)
            }
        } catch {
            throw MotivationError.unknownError(error.localizedDescription)
        }
    }

    /// Clears the internal quote cache
    func clearCache() {
        cachedQuotes.removeAll()
        lastFetchTime = nil
    }
}

// MARK: - Error Types

enum MotivationError: LocalizedError {
    case invalidURL
    case networkError(String)
    case decodingError(String)
    case unknownError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .networkError(let message):
            return message
        case .decodingError(let message):
            return "Failed to decode response: \(message)"
        case .unknownError(let message):
            return "An error occurred: \(message)"
        }
    }
}
