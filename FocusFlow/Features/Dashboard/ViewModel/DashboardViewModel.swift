import Foundation
import SwiftUI
import Combine
import HealthKit
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


/// ViewModel simplificado (liga depois aos teus services

final class DashboardViewModel: ObservableObject {
    // Estado exibido
    @Published var missingPermissions: [PermissionKind] = []
    @Published var health: HealthProgress = .init(progress: 0.0,
                                                  title: "Daily Activity",
                                                  detail: "No data")
    @Published var nextBlock: FocusBlock?
    @Published var usage: UsageSummary = .init(usedMinutes: 0,
                                               limitMinutes: nil,
                                               topAppName: nil,
                                               topAppMinutes: nil)
    @Published var isFocusingNow: Bool = false
    @Published var isLoading: Bool = true
    @Published var tip: String = "Tiny progress is still progress."
    
    // Ações (integra com serviços reais)
    func focusNow() {
        isFocusingNow = true
    }

    func stopFocus() {
        isFocusingNow = false
    }

    func takeBreak5Min() {
        // TODO
    }

    func openPlanner() {
        // Navegação feita na View com closure
    }

    // Carrega dados (agora com HealthKit)
    @MainActor
    func load() {
        isLoading = true
        
        // --- mocks de restante informação (como tinhas) ---
        let cal = Calendar.current
        let now = Date()
        let start = cal.date(bySettingHour: 18, minute: 0, second: 0, of: now)!
        let end   = cal.date(bySettingHour: 20, minute: 0, second: 0, of: now)!

        self.nextBlock = FocusBlock(id: .init(),
                                    title: "Evening Focus",
                                    start: start,
                                    end: end)
        
        self.usage = .init(usedMinutes: 23,
                           limitMinutes: 30,
                           topAppName: "Instagram",
                           topAppMinutes: 12)
        
        self.missingPermissions = [] // ex.: [.screenTime]
        self.tip = "Protect the next hour like a meeting with yourself."
        
        // --- Health progress a partir do HealthKit ---
        let goalSteps = 10_000
        
        HealthKitManager.shared.fetchTodaySteps { [weak self] steps in
            guard let self = self else { return }
            
            print("DashboardViewModel.load – steps from HealthKit:", steps)
            
            let clampedSteps = max(0, steps)
            let progress = min(Double(clampedSteps) / Double(goalSteps), 1.0)
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            
            let stepsString = formatter.string(from: NSNumber(value: clampedSteps)) ?? "\(clampedSteps)"
            let goalString  = formatter.string(from: NSNumber(value: goalSteps)) ?? "\(goalSteps)"
            
            self.health = .init(
                progress: progress,
                title: "Daily Activity",
                detail: "\(stepsString) / \(goalString) steps"
            )
            
            self.isLoading = false
        }
    }
}
