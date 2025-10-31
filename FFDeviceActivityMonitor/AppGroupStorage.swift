import Foundation

// Read shared credits from App Group
struct AppGroupStorageMonitor {
    let suiteName = "group.com.example.FocusFlow"
    var defaults: UserDefaults? { UserDefaults(suiteName: suiteName) }
}
