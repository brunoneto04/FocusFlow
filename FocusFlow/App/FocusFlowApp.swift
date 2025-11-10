import SwiftUI

@main
struct FocusFlowApp: App {
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                // Show the dashboard as the app's root
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
}
