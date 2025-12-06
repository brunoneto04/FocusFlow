//
//  DashboardView.swift
//  FocusFlow
//

import SwiftUI
import Foundation
import FamilyControls   // importante para AuthorizationStatus

struct DashboardView: View {
    @StateObject private var vm = DashboardViewModel()
    @Environment(\.colorScheme) private var colorScheme

    @State private var showHealthSetup = false
    @State private var showScreenTimeSetup = false
    @State private var isRequestingScreenTime = false   // loading do botão
    @State private var animateGlow: Bool = false

    /// Closure de navegação, passada pelo RootView via AppRouter
    let navigate: (AppRoute) -> Void

    @AppStorage("isHealthConnected") private var isHealthConnected: Bool = false

    @ObservedObject private var screenTimeManager = ScreenTimeManager.shared

    var body: some View {
        ZStack {
            // Background gradient matching OnboardingView
            OnboardingTheme.backgroundGradient
                .ignoresSafeArea()
            
            // Animated glow background
            DashboardGlowBackground(isAnimating: animateGlow)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Banner de permissões em falta
                    if !vm.missingPermissions.isEmpty {
                        PermissionBanner(
                            missing: vm.missingPermissions,
                            onGrant: {
                                showHealthSetup = true
                            }
                        )
                    }

                    // 1) Health – aparece se ainda não estiver ligado
                    if !isHealthConnected {
                        PermissionCard(
                            systemImage: "heart.fill",
                            title: "Connect Apple Health",
                            subtitle: "Turn your steps into extra screen time.",
                            buttonTitle: "Connect Health",
                            isLoading: false
                        ) {
                            showHealthSetup = true
                        }
                    }

                    // 2) Screen Time – aparece se ainda não tiver autorização aprovada
                    if screenTimeManager.authorizationStatus != .approved {
                        PermissionCard(
                            systemImage: "hourglass.circle.fill",
                            title: "Connect Screen Time",
                            subtitle: "Let FocusFlow manage which apps you can use based on your activity.",
                            buttonTitle: isRequestingScreenTime ? "Requesting..." : "Connect Screen Time",
                            isLoading: isRequestingScreenTime
                        ) {
                            requestScreenTimePermission()
                        }
                    }

                    // Conteúdo principal do dashboard
                    TodayProgressSection(health: vm.health)

                    NextFocusBlockCard(block: vm.nextBlock)

                    UsageSummaryCard(
                        usage: vm.usage,
                        onOpenReport: {
                            navigate(.planner)
                        }
                    )

                    QuickActionsBar(
                        isFocusing: vm.isFocusingNow,
                        onFocus: vm.focusNow,
                        onStop: vm.stopFocus,
                        onBreak: vm.takeBreak5Min,
                        onPlanner: {
                            navigate(.planner)
                        }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            
            if vm.isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Dashboard")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            animateGlow = true
        }
        .task {
             vm.load()
        }
        // Sheet para setup do Health
        .sheet(isPresented: $showHealthSetup) {
            HealthSetupView {
                showHealthSetup = false
                Task {
                     vm.load()
                }
            }
        }
        // Sheet para setup do Screen Time
        .sheet(isPresented: $showScreenTimeSetup) {
            ScreenTimeSetupView()
        }
    }

    // MARK: - Screen Time

    private func requestScreenTimePermission() {
        guard !isRequestingScreenTime else { return }
        isRequestingScreenTime = true

        Task {
            do {
                try await screenTimeManager.requestAuthorization()
                isRequestingScreenTime = false

                if screenTimeManager.authorizationStatus == .approved {
                    // Depois de aprovar, abres o ecrã onde escolhes apps/websites
                    showScreenTimeSetup = true
                }
            } catch {
                isRequestingScreenTime = false
                print("Screen Time authorization failed: \(error)")
            }
        }
    }
}

// MARK: - Dashboard Glow Background
private struct DashboardGlowBackground: View {
    let isAnimating: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(OnboardingTheme.accentGradient)
                .frame(width: 320, height: 320)
                .blur(radius: 140)
                .scaleEffect(isAnimating ? 1.2 : 0.8)
                .offset(x: -120, y: -220)
                .opacity(0.6)
                .animation(OnboardingAnimation.glow, value: isAnimating)

            Circle()
                .fill(OnboardingTheme.accentGradient)
                .frame(width: 260, height: 260)
                .blur(radius: 120)
                .scaleEffect(isAnimating ? 1.05 : 0.85)
                .offset(x: 140, y: 200)
                .opacity(0.45)
                .animation(OnboardingAnimation.glow, value: isAnimating)
        }
    }
}
