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
            NavigationView {
                ZStack {
                    // root screen
                    DashboardView(navigate: router.navigate(to:))

                    // programmatic navigation using selection
                    NavigationLink(
                        destination: Text("Planner"),   // replace with PlannerView()
                        tag: AppRoute.planner,
                        selection: $router.selectedRoute
                    ) { EmptyView() }
                        .hidden()

                    NavigationLink(
                        destination: Text("Reports"),   // replace with ReportsView()
                        tag: AppRoute.reports,
                        selection: $router.selectedRoute
                    ) { EmptyView() }
                        .hidden()

                    NavigationLink(
                        destination: Text("Settings"),  // replace with SettingsView()
                        tag: AppRoute.settings,
                        selection: $router.selectedRoute
                    ) { EmptyView() }
                        .hidden()
                }
                .navigationTitle("Dashboard")
            }
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            .tag(MainTab.dashboard)

            // MOTIVATION TAB
            NavigationView {
                Text("Motivation") // MotivationView()
                    .navigationTitle("Motivation")
            }
            .tabItem {
                Label("Motivation", systemImage: "lightbulb.fill")
            }
            .tag(MainTab.motivation)

            // SETTINGS TAB
            NavigationView {
                Text("Settings") // SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(MainTab.settings)
        }
        .tint(.blue) // iOS 15 ok
        .environmentObject(router)
    }
}
