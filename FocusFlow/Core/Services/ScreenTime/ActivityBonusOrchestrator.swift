import Foundation
import Combine

@MainActor
final class ActivityBonusOrchestrator: ObservableObject {
    @Published private(set) var blockedGroupIdentifier: String?
    @Published private(set) var availableBonusMinutes: Int = 0
    @Published private(set) var activeUnlockUntil: Date?
    @Published private(set) var lastKnownSteps: Int = 0
    @Published private(set) var bonusState: StepBonusState

    private let configuration: StepBonusConfiguration
    private let healthKit: HealthKitManager
    private let screenTimeManager: ScreenTimeManager
    private let bonusEngine: StepBonusCalculating
    private let calendar: Calendar

    private var reshieldTask: Task<Void, Never>?
    private var lastBonusDay: Date

    init(
        configuration: StepBonusConfiguration,
        calendar: Calendar = .current,
        healthKit: HealthKitManager = .shared,
        screenTimeManager: ScreenTimeManager = .shared,
        bonusEngine: StepBonusCalculating? = nil
    ) {
        self.configuration = configuration
        self.calendar = calendar
        self.healthKit = healthKit
        self.screenTimeManager = screenTimeManager
        self.bonusEngine = bonusEngine ?? StepBonusEngine(configuration: configuration, calendar: calendar)
        let today = calendar.startOfDay(for: Date())
        self.lastBonusDay = today
        self.bonusState = StepBonusState(lastEvaluatedDay: today)
    }

    deinit {
        reshieldTask?.cancel()
    }

    func markLimitReached(for groupIdentifier: String) {
        blockedGroupIdentifier = groupIdentifier
        screenTimeManager.applySelectedShield()
    }

    func clearLimit() {
        blockedGroupIdentifier = nil
        activeUnlockUntil = nil
        reshieldTask?.cancel()
        screenTimeManager.clearShield()
    }

    func refreshStepsAndBonus() async {
        let steps = (try? await healthKit.fetchTodaySteps()) ?? 0
        lastKnownSteps = steps

        let today = calendar.startOfDay(for: Date())
        if today != lastBonusDay {
            availableBonusMinutes = 0
            activeUnlockUntil = nil
            reshieldTask?.cancel()
            lastBonusDay = today
        }

        let grant = bonusEngine.evaluate(steps: steps, day: today, state: bonusState)
        bonusState = grant.updatedState

        if grant.newlyEarnedMinutes > 0 {
            availableBonusMinutes = min(configuration.maxDailyBonusMinutes, availableBonusMinutes + grant.newlyEarnedMinutes)
        }
    }

    func startBonusSession(minutes: Int? = nil) {
        guard blockedGroupIdentifier != nil else { return }
        guard availableBonusMinutes > 0 else { return }

        let minutesToUse = min(availableBonusMinutes, minutes ?? availableBonusMinutes)
        availableBonusMinutes -= minutesToUse

        let unlockEndDate = Date().addingTimeInterval(TimeInterval(minutesToUse * 60))
        activeUnlockUntil = unlockEndDate

        reshieldTask?.cancel()
        screenTimeManager.clearShield()

        reshieldTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(minutesToUse * 60) * 1_000_000_000)
            await MainActor.run {
                guard let self else { return }
                self.activeUnlockUntil = nil
                if self.blockedGroupIdentifier != nil {
                    self.screenTimeManager.applySelectedShield()
                }
            }
        }
    }
}
