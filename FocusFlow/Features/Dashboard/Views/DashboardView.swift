import SwiftUI

struct DashboardView: View {
    @StateObject private var vm = DashboardViewModel()
    let navigate: (AppRoute) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if !vm.missingPermissions.isEmpty {
                    PermissionBanner(missing: vm.missingPermissions,
                                     onGrant: { navigate(.settings) })
                }

                TodayProgressSection(health: vm.health)

                NextFocusBlockCard(block: vm.nextBlock)

                UsageSummaryCard(usage: vm.usage,
                                 onOpenReport: { navigate(.planner) }) // ou rota para Reports

                QuickActionsBar(isFocusing: vm.isFocusingNow,
                                onFocus: vm.focusNow,
                                onStop: vm.stopFocus,
                                onBreak: vm.takeBreak5Min,
                                onPlanner: { navigate(.planner) })

              //  MotivationTipView(text: vm.tip)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .navigationTitle("Dashboard")
        .overlay {
            if vm.isLoading {
                ProgressView().progressViewStyle(.circular)
            }
        }
        .task { vm.load() }
    }
}
