import SwiftUI
import Combine
import FamilyControls
@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Persisted Values
    @AppStorage("stepGoal") var stepGoal: Int = 10000
    @AppStorage("dailyLimitMinutes") var dailyLimitMinutes: Int = 90
    @AppStorage("blockDurationMinutes") var blockDurationMinutes: Int = 25
    @AppStorage("focusRemindersEnabled") var focusRemindersEnabled: Bool = true
    @AppStorage("focusHapticsEnabled") var focusHapticsEnabled: Bool = true
    @AppStorage("isHealthConnected") var isHealthConnected: Bool = false

    // MARK: - Dependencies
    @ObservedObject var screenTimeManager = ScreenTimeManager.shared

    // MARK: - Helpers
    var healthStatusText: String {
        isHealthConnected ? "Connected" : "Not Connected"
    }

    var screenTimeStatusText: String {
        switch screenTimeManager.authorizationStatus {
        case .approved:
            return "Approved"
        case .denied:
            return "Denied"
        case .notDetermined:
            fallthrough
        @unknown default:
            return "Not Requested"
        }
    }

    var screenTimeStatusColor: Color {
        switch screenTimeManager.authorizationStatus {
        case .approved:
            return .green
        case .denied:
            return .red
        case .notDetermined:
            fallthrough
        @unknown default:
            return .orange
        }
    }

    var formattedDailyLimit: String {
        let hours = dailyLimitMinutes / 60
        let minutes = dailyLimitMinutes % 60

        if hours == 0 {
            return "\(minutes) min"
        } else if minutes == 0 {
            return "\(hours) h"
        } else {
            return "\(hours) h \(minutes) min"
        }
    }
}
