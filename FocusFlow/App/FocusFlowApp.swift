import SwiftUI

@main
struct FocusFlowApp: App {
    @StateObject private var dashboardVM = DashboardViewModel()
    @StateObject private var router = AppRouter()


    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                DashboardView(viewModel: dashboardVM,navigate: router.navigate(to:))
                    .navigationDestination(for: AppRoute.self) { route in
                    // Destinos de navegação
                        switch route {
                        case .dashboard:
                            DashboardView(viewModel: dashboardVM, navigate: router.navigate(to:))
                        case .planner:
                            PlannerView()
                        case .reports:
                            ReportsView()
                        case .settings:
                            SettingsView()
                        }
                    }
            }
            Text("FocusFlow — App placeholder")
                .padding()
        }
    }
}
