//
//  RouteView.swift
//  FocusFlow
//
//  Created by formando on 10/11/2025.
//

import SwiftUI

struct RootView: View {
    @StateObject private var router = AppRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            DashboardView(navigate: router.navigate(to:))
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .dashboard:
                        DashboardView(navigate: router.navigate(to:))
                    case .planner:
                        Text("Planner")
                    case .reports:
                        Text("Reports")
                    case .settings:
                        Text("Settings")
                    }
                }
        }
    }
}

