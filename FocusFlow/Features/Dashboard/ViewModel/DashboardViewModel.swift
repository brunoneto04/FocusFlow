import Foundation
import SwiftUI
import Combine
// Modelos simples para a Dashboard
struct FocusBlock: Identifiable, Hashable {
    let id: UUID
    let title: String
    let start: Date
    let end: Date
    var durationMinutes: Int { Int(end.timeIntervalSince(start) / 60) }
}

struct HealthProgress {
    let progress: Double     // 0...1
    let title: String        // ex. "Daily Activity"
    let detail: String       // ex. "6,200 / 8,000 steps"
}

struct UsageSummary {
    let usedMinutes: Int
    let limitMinutes: Int?   // pode ser nil
    let topAppName: String?
    let topAppMinutes: Int?
}

enum PermissionKind: String, Identifiable {
    case screenTime, healthKit
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .screenTime: return "Screen Time"
        case .healthKit:  return "Health"
        }
    }
}


/// ViewModel simplificado (liga depois aos teus services)
final class DashboardViewModel: ObservableObject {
    // Estado exibido
    @Published var missingPermissions: [PermissionKind] = []
    @Published var health: HealthProgress = .init(progress: 0.0, title: "Daily Activity", detail: "No data")
    @Published var nextBlock: FocusBlock?
    @Published var usage: UsageSummary = .init(usedMinutes: 0, limitMinutes: nil, topAppName: nil, topAppMinutes: nil)
    @Published var isFocusingNow: Bool = false
    @Published var isLoading: Bool = true
    @Published var tip: String = "Tiny progress is still progress."

    // Ações (integra com serviços reais)
    func focusNow() {
        // TODO: chamar ScreenTimeService para aplicar shields imediatos
        isFocusingNow = true
    }

    func stopFocus() {
        // TODO: remover shields
        isFocusingNow = false
    }

    func takeBreak5Min() {
        // TODO: pedir 'break' de 5 minutos via App Group / Monitor
    }

    func openPlanner() {
        // A navegação é feita na View com closure, este método é um placeholder
    }

    // Carrega mocks (substitui por fetch real de serviços)
    @MainActor
    func load() {
        isLoading = true
        // Simulação de dados
        let cal = Calendar.current
        let now = Date()
        let start = cal.date(bySettingHour: 18, minute: 0, second: 0, of: now)!
        let end   = cal.date(bySettingHour: 20, minute: 0, second: 0, of: now)!

        self.health = .init(progress: 0.62, title: "Daily Activity", detail: "6,200 / 10,000 steps")
        self.nextBlock = FocusBlock(id: .init(), title: "Evening Focus", start: start, end: end)
        self.usage = .init(usedMinutes: 23, limitMinutes: 30, topAppName: "Instagram", topAppMinutes: 12)
        self.missingPermissions = [] // ex.: [.screenTime]
        self.tip = "Protect the next hour like a meeting with yourself."
        self.isLoading = false
    }
}
