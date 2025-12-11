import Foundation
import SwiftUI
import Combine
import HealthKit
import UIKit

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
@MainActor
final class DashboardViewModel: ObservableObject {
    // MARK: - Persisted settings
    @AppStorage("stepGoal") private var stepGoal: Int = 10_000
    @AppStorage("dailyLimitMinutes") private var dailyLimitMinutes: Int = 90
    @AppStorage("blockDurationMinutes") private var blockDurationMinutes: Int = 25
    @AppStorage("focusRemindersEnabled") private var focusRemindersEnabled: Bool = true
    @AppStorage("focusHapticsEnabled") private var focusHapticsEnabled: Bool = true
    @AppStorage("userGoal") private var storedUserGoal: String = ""

    private var stepConfiguration: StepBonusConfiguration {
        StepBonusConfiguration(
            dailyStepGoal: stepGoal,
            baseBonusMinutes: 15,
            bonusStepsPerBlock: 2_000,
            bonusMinutesPerBlock: 5,
            maxDailyBonusMinutes: 45
        )
    }

    var bonusConfiguration: StepBonusConfiguration { stepConfiguration }

    // Estado exibido
    @Published var missingPermissions: [PermissionKind] = []
    @Published var health: HealthProgress = .init(
        progress: 0.0,
        title: "Daily Activity",
        detail: "No data"
    )
    @Published var nextBlock: FocusBlock?
    @Published var usage: UsageSummary = .init(
        usedMinutes: 0,
        limitMinutes: nil,
        topAppName: nil,
        topAppMinutes: nil
    )
    @Published var isFocusingNow: Bool = false
    @Published var isLoading: Bool = true
    @Published var tip: String = "Tiny progress is still progress."
    @Published var blockedGroupIdentifier: String?
    @Published var availableBonusMinutes: Int = 0
    @Published var activeUnlockUntil: Date?
    @Published var currentSteps: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    public let activityBonus: ActivityBonusOrchestrator
    private var focusReminderTask: Task<Void, Never>?

    init(activityBonus: ActivityBonusOrchestrator? = nil) {
        if let provided = activityBonus {
            self.activityBonus = provided
        } else {
            self.activityBonus = ActivityBonusOrchestrator(
                configuration: StepBonusConfiguration(
                    dailyStepGoal: 10_000,
                    baseBonusMinutes: 15,
                    bonusStepsPerBlock: 2_000,
                    bonusMinutesPerBlock: 5,
                    maxDailyBonusMinutes: 45
                )
            )
        }
        bindOrchestrator(self.activityBonus)
    }

    // Ações (integra com serviços reais)
    func focusNow() {
        isFocusingNow = true
        triggerFocusHaptic()
        scheduleFocusReminder()
    }

    func stopFocus() {
        isFocusingNow = false
        focusReminderTask?.cancel()
    }

    func takeBreak5Min() {
        focusReminderTask?.cancel()
        isFocusingNow = false
    }

    func openPlanner() {
        // Navegação feita na View com closure
    }

    // Carrega dados (agora com HealthKit)
    func load() {
        isLoading = true
        
        // --- mocks de restante informação (como tinhas) ---
        let start = Date()
        let end   = start.addingTimeInterval(TimeInterval(blockDurationMinutes * 60))

        self.nextBlock = FocusBlock(
            id: .init(),
            title: "Evening Focus",
            start: start,
            end: end
        )

        self.usage = .init(
            usedMinutes: 30,
            limitMinutes: dailyLimitMinutes,
            topAppName: "Instagram",
            topAppMinutes: 12
        )

        self.missingPermissions = [] // ex.: [.screenTime]
        self.tip = personalizedTip()
        syncShieldingState()

        // Task no MainActor para poder chamar HealthKitManager e ActivityBonusOrchestrator
        Task { @MainActor in
            _ = await HealthKitManager.shared.requestAuthorization()
            await self.activityBonus.refreshStepsAndBonus()
            self.isLoading = false
        }
    }

    private func bindOrchestrator(_ orchestrator: ActivityBonusOrchestrator) {
        orchestrator.$blockedGroupIdentifier
            .receive(on: RunLoop.main)
            .assign(to: &self.$blockedGroupIdentifier)

        orchestrator.$availableBonusMinutes
            .receive(on: RunLoop.main)
            .assign(to: &self.$availableBonusMinutes)

        orchestrator.$activeUnlockUntil
            .receive(on: RunLoop.main)
            .assign(to: &self.$activeUnlockUntil)

        orchestrator.$lastKnownSteps
            .sink { [weak self] steps in
                guard let self else { return }
                Task { @MainActor in
                    self.currentSteps = steps
                    self.updateHealthProgress(steps: steps)
                }
            }
            .store(in: &cancellables)
    }

    private func updateHealthProgress(steps: Int) {
        let clampedSteps = max(0, steps)
        let progress = min(
            Double(clampedSteps) / Double(stepConfiguration.dailyStepGoal),
            1.0
        )

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        let stepsString = formatter.string(from: NSNumber(value: clampedSteps)) ?? "\(clampedSteps)"
        let goalString  = formatter.string(from: NSNumber(value: stepConfiguration.dailyStepGoal)) ?? "\(stepConfiguration.dailyStepGoal)"

        health = .init(
            progress: progress,
            title: "Daily Activity",
            detail: "\(stepsString) / \(goalString) steps"
        )
    }

    private func personalizedTip() -> String {
        switch UserGoal(rawValue: storedUserGoal) {
        case .studyLessDistracted:
            return "Protect this session like an important class."
        case .reduceSocialMedia:
            return "Use your limit to curb scrolling—your future self will thank you."
        case .sleepBetter:
            return "Wind down: focus time now means better rest later."
        case .justCurious:
            return "Small tweaks lead to big changes. Explore what works for you."
        case .none:
            return "Protect the next hour like a meeting with yourself."
        }
    }

    private func syncShieldingState() {
        if let limit = usage.limitMinutes, usage.usedMinutes >= limit {
            activityBonus.markLimitReached(for: "PrimaryLimitGroup")
        } else {
            activityBonus.clearLimit()
        }
    }

    private func scheduleFocusReminder() {
        focusReminderTask?.cancel()

        guard focusRemindersEnabled else { return }

        focusReminderTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(blockDurationMinutes * 60) * 1_000_000_000)

            await MainActor.run {
                guard let self, self.isFocusingNow else { return }
                self.tip = "Time's up for this block—take a short break."
            }
        }
    }

    private func triggerFocusHaptic() {
        guard focusHapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
