//
//  AppRoute.swift
//  		
//
//  Created by formando on 10/11/2025.
//

import SwiftUI
import Combine

final class AppRouter: ObservableObject {
    /// Current pushed route from the Dashboard.
    /// `nil` means we are on the Dashboard itself.
    @Published var selectedRoute: AppRoute? = nil

    func navigate(to route: AppRoute) {
        // If you ever call .dashboard, go back to root
        if route == .dashboard {
            selectedRoute = nil
        } else {
            selectedRoute = route
        }
    }

    func pop() {
        // Go back to Dashboard
        selectedRoute = nil
    }

    func popToRoot() {
        // Same as pop in this simple routing model
        selectedRoute = nil
    }
}

