//
//  DashboardView.swift
//  FocusFlow
//

import SwiftUI
import FamilyControls   // importante para AuthorizationStatus

struct DashboardView: View {
    @StateObject private var vm = DashboardViewModel()

    @State private var showHealthSetup = false
    @State private var showScreenTimeSetup = false
    @State private var isRequestingScreenTime = false   // loading do botão

    /// Closure de navegação, passada pelo RootView via AppRouter
    let navigate: (AppRoute) -> Void

    @AppStorage("isHealthConnected") private var isHealthConnected: Bool = false

    @ObservedObject private var screenTimeManager = ScreenTimeManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
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
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .navigationTitle("Dashboard")
        .overlay {
            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
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
