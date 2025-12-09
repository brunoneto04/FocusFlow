import Foundation

// MARK: - Models

/// Represents a motivational quote from ZenQuotes API
struct MotivationQuote: Identifiable, Codable, Equatable {
    let id: String
    let content: String
    let author: String
    let html: String
    
    enum CodingKeys: String, CodingKey {
        case content = "q"
        case author = "a"
        case html = "h"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.content = try container.decode(String.self, forKey: .content)
        self.author = try container.decode(String.self, forKey: .author)
        self.html = try container.decode(String.self, forKey: .html)
        // Generate a stable ID from content and author
        self.id = "\(content)-\(author)".hashValue.description
    }
    
    init(content: String, author: String, html: String = "") {
        self.id = "\(content)-\(author)".hashValue.description
        self.content = content
        self.author = author
        self.html = html
    }
    
    /// Creates a sample quote for previews/testing
    static var sample: MotivationQuote {
        MotivationQuote(
            content: "The only way to do great work is to love what you do.",
            author: "Steve Jobs"
        )
    }
    
    /// Creates a motivational quote for staying focused
    static var focusSample: MotivationQuote {
        MotivationQuote(
            content: "Concentrate all your thoughts upon the work in hand. The sun's rays do not burn until brought to a focus.",
            author: "Alexander Graham Bell"
        )
    }
    
    /// Fallback quote for offline/error states
    static var fallback: MotivationQuote {
        MotivationQuote(
            content: "The journey of a thousand miles begins with one step.",
            author: "Lao Tzu"
        )
    }
}
