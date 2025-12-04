import SwiftUI
import FamilyControls

struct PermissionsSectionView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @StateObject private var screenTimeManager = ScreenTimeManager.shared

    @State private var isRequestingHealth = false
    @State private var isRequestingScreenTime = false
    @State private var isScreenTimePickerPresented = false

    var body: some View {
        VStack(spacing: 16) {
            // Permissão do Apple Health
            if !hasHealthPermission {
                PermissionCard(
                    systemImage: "heart.fill",
                    title: "Connect Apple Health",
                    subtitle: "We need access to your step data to convert activity into extra screen time.",
                    buttonTitle: isRequestingHealth ? "Requesting..." : "Allow Health access",
                    isLoading: isRequestingHealth
                ) {
                    requestHealthPermission()
                }
            }

            // Permissão do Screen Time / Family Controls
            if screenTimeManager.authorizationStatus != .approved {
                PermissionCard(
                    systemImage: "hourglass.circle.fill",
                    title: "Connect Screen Time",
                    subtitle: "Allow FocusFlow to manage which apps can be used based on your activity.",
                    buttonTitle: isRequestingScreenTime ? "Requesting..." : "Allow Screen Time access",
                    isLoading: isRequestingScreenTime
                ) {
                    requestScreenTimePermission()
                }
            }
        }
        .animation(.default, value: hasHealthPermission)
        .animation(.default, value: screenTimeManager.authorizationStatus)
        .familyActivityPicker(
            isPresented: $isScreenTimePickerPresented,
            selection: $screenTimeManager.selection
        )
    }

    // MARK: - Helpers

    private var hasHealthPermission: Bool {
        healthManager.isAuthorized
    }

    private func requestHealthPermission() {
        guard !isRequestingHealth else { return }
        isRequestingHealth = true

        healthManager.requestAuthorization { success in
            if !success {
                print("HealthKit authorization failed or not granted")
            }
            isRequestingHealth = false
        }
    }

    private func requestScreenTimePermission() {
        guard !isRequestingScreenTime else { return }
        isRequestingScreenTime = true

        Task {
            do {
                try await screenTimeManager.requestAuthorization()
                if screenTimeManager.authorizationStatus == .approved {
                    isScreenTimePickerPresented = true
                }
            } catch {
                print("Screen Time authorization failed: \(error)")
            }
            isRequestingScreenTime = false
        }
    }
}
