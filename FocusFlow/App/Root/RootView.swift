//
//  RouteView.swift
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

            // DASHBOARD TAB
            NavigationStack(path: $router.path) {
                DashboardView(navigate: router.navigate(to:))
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .dashboard:
                            DashboardView(navigate: router.navigate(to:))
                        case .planner:
                            Text("Planner")      // replace with PlannerView()
                        case .reports:
                            Text("Reports")      // replace with ReportsView()
                        case .settings:
                            Text("Settings")     // can push settings from dashboard if you want
                        }
                    }
            }
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            .tag(MainTab.dashboard)

            // MOTIVATION TAB
            NavigationStack {
               // MotivationView()                 // create this screen
            }
            .tabItem {
                Label("Motivation", systemImage: "lightbulb.fill")
            }
            .tag(MainTab.motivation)

            // BLOCKED APPS TAB
            NavigationStack {
               // BlockedAppsView()                // list of blocked apps, toggles, etc.
            }
            .tabItem {
                Label("Blocked", systemImage: "lock.app")
            }
            .tag(MainTab.blocked)

            // SETTINGS TAB
            NavigationStack {
               // SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(MainTab.settings)
        }
        .tint(.blue) // selected tab + accent
    }
}


