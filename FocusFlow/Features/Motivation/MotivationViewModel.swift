import Foundation
import Combine
// MARK: - View Model

/// ViewModel managing the state and business logic for the Motivation feature
@MainActor
final class MotivationViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentQuote: MotivationQuote = .fallback
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var favoriteQuotes: [MotivationQuote] = []
    @Published var quoteHistory: [MotivationQuote] = []
    
    // MARK: - Private Properties
    
    private let service = MotivationService.shared
    private let favoritesKey = "FocusFlow.favoriteQuotes"
    private var currentHistoryIndex = 0
    
    // MARK: - Initialization
    
    init() {
        loadFavorites()
        Task {
            await loadInitialQuote()
        }
    }
    
    // MARK: - Public Methods
    

    /// Fetches a new random quote
    func fetchNewQuote() async {
        isLoading = true
        errorMessage = nil

        do {
            // Always fetch fresh quote from API, bypassing cache
            let newQuote = try await service.fetchRandomQuote(ignoreCache: true)

            // Add to history if it's different from current
            if newQuote.id != currentQuote.id {
                quoteHistory.append(currentQuote)
                currentHistoryIndex = quoteHistory.count
            }

            currentQuote = newQuote

        } catch let error as MotivationError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "An unexpected error occurred"
        }

        isLoading = false
    }
    
    /// Fetches today's special quote
    func fetchTodayQuote() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let todayQuote = try await service.fetchTodayQuote()
            
            if todayQuote.id != currentQuote.id && currentQuote.id != MotivationQuote.fallback.id {
                quoteHistory.append(currentQuote)
                currentHistoryIndex = quoteHistory.count
            }
            
            currentQuote = todayQuote
            
        } catch let error as MotivationError {
            errorMessage = error.errorDescription
            print("❌ Error fetching today's quote: \(error.errorDescription ?? "Unknown error")")
            // Fallback to random quote
            await fetchNewQuote()
        } catch {
            errorMessage = "An unexpected error occurred"
            print("❌ Unexpected error: \(error)")
            await fetchNewQuote()
        }
        
        isLoading = false
    }
    
    /// Navigates to the previous quote in history
    func previousQuote() {
        guard currentHistoryIndex > 0, !quoteHistory.isEmpty else { return }
        currentHistoryIndex -= 1
        currentQuote = quoteHistory[currentHistoryIndex]
    }
    
    /// Navigates to the next quote in history
    func nextQuote() {
        guard currentHistoryIndex < quoteHistory.count - 1 else {
            Task { await fetchNewQuote() }
            return
        }
        currentHistoryIndex += 1
        currentQuote = quoteHistory[currentHistoryIndex]
    }
    
    /// Checks if we can navigate to previous quote
    var canNavigatePrevious: Bool {
        currentHistoryIndex > 0 && !quoteHistory.isEmpty
    }
    
    /// Checks if we can navigate to next quote
    var canNavigateNext: Bool {
        currentHistoryIndex < quoteHistory.count - 1
    }
    
    /// Checks if the current quote is favorited
    func isCurrentQuoteFavorited() -> Bool {
        favoriteQuotes.contains(where: { $0.id == currentQuote.id })
    }
    
    /// Toggles the favorite status of the current quote
    func toggleFavorite() {
        if let index = favoriteQuotes.firstIndex(where: { $0.id == currentQuote.id }) {
            favoriteQuotes.remove(at: index)
        } else {
            favoriteQuotes.append(currentQuote)
        }
        saveFavorites()
    }
    
    /// Removes a quote from favorites
    func removeFavorite(_ quote: MotivationQuote) {
        favoriteQuotes.removeAll(where: { $0.id == quote.id })
        saveFavorites()
    }
    
    // MARK: - Private Methods
    
    private func loadInitialQuote() async {
        await fetchNewQuote()
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteQuotes) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey),
              let decoded = try? JSONDecoder().decode([MotivationQuote].self, from: data) else {
            return
        }
        favoriteQuotes = decoded
    }
}

// MARK: - Preview Helper

#if DEBUG
extension MotivationViewModel {
    static var preview: MotivationViewModel {
        let vm = MotivationViewModel()
        vm.currentQuote = .sample
        return vm
    }
    
    static var previewLoading: MotivationViewModel {
        let vm = MotivationViewModel()
        vm.isLoading = true
        return vm
    }
}
#endif
