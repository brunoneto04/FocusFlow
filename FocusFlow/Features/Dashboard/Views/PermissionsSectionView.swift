//
//  PermissionsSectionView.swift
//  FocusFlow
//
//  Created by formando on 27/11/2025.
//


import SwiftUI
import FamilyControls

struct PermissionsSectionView: View {
    @EnvironmentObject var healthManager: HealthManager          // adapta ao teu tipo
    @StateObject private var screenTimeManager = ScreenTimeManager.shared

    @State private var isRequestingHealth = false
    @State private var isRequestingScreenTime = false
    @State private var isScreenTimePickerPresented = false

    var body: some View {
        VStack(spacing: 16) {
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
        .familyActivityPicker(
            isPresented: $isScreenTimePickerPresented,
            selection: $screenTimeManager.selection
        )
    }

    // MARK: - Helpers

    private var hasHealthPermission: Bool {
        // adapta isto ao que já tens no teu HealthManager
        healthManager.isAuthorized
    }

    private func requestHealthPermission() {
        guard !isRequestingHealth else { return }
        isRequestingHealth = true

        Task {
            do {
                try await healthManager.requestAuthorization()
            } catch {
                print("HealthKit authorization failed: \(error)")
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
                // depois de autorizado, abrimos logo o picker
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
