//
//  RootView.swift
//  FocusFlow
//
//  Created by formando on 10/11/2025.
//

import SwiftUI
import Combine

struct RootView: View {
    @StateObject private var router = AppRouter()
    @State private var selectedTab: MainTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {

            // MARK: - DASHBOARD TAB
            NavigationStack(path: $router.path) {
                DashboardView(navigate: router.navigate(to:))
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .dashboard:
                            // Se algum dia quiseres navegar explicitamente para o dashboard
                            DashboardView(navigate: router.navigate(to:))

                        case .planner:
                            // TODO: substituir por PlannerView()
                            Text("Planner")
                                .navigationTitle("Planner")

                        case .reports:
                            // TODO: substituir por ReportsView()
                            Text("Reports")
                                .navigationTitle("Reports")

                        case .settings:
                            // TODO: podes navegar para um ecrã de settings mais profundo
                            Text("Settings")
                                .navigationTitle("Settings")
                        }
                    }
            }
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            .tag(MainTab.dashboard)

            // MARK: - MOTIVATION TAB
            NavigationStack {
                // TODO: troca por MotivationView()
                Text("Motivation")
                    .navigationTitle("Motivation")
            }
            .tabItem {
                Label("Motivation", systemImage: "lightbulb.fill")
            }
            .tag(MainTab.motivation)

            // MARK: - BLOCKED TAB
            NavigationStack {
                // TODO: troca por BlockedAppsView() ou semelhante
                Text("Blocked Apps")
                    .navigationTitle("Blocked Apps")
            }
            .tabItem {
                Label("Blocked", systemImage: "lock.fill")
            }
            .tag(MainTab.blocked)

            // MARK: - SETTINGS TAB
            NavigationStack {
                // TODO: troca por SettingsRootView()
                Text("Settings")
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(MainTab.settings)
        }
        .tint(.blue)
        .environmentObject(router)
    }
}
