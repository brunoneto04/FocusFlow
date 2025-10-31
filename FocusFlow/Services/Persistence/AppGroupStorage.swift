import Foundation

// Simple UserDefaults (App Group) wrapper placeholder
struct AppGroupStorage {
    let suiteName = "group.com.example.FocusFlow"
    var defaults: UserDefaults? { UserDefaults(suiteName: suiteName) }
}
