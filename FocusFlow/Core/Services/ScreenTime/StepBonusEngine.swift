import Foundation

protocol StepBonusCalculating {
    func evaluate(steps: Int, day: Date, state: StepBonusState) -> StepBonusGrant
}

struct StepBonusConfiguration: Equatable {
    let dailyStepGoal: Int
    let baseBonusMinutes: Int
    let bonusStepsPerBlock: Int
    let bonusMinutesPerBlock: Int
    let maxDailyBonusMinutes: Int

    init(
        dailyStepGoal: Int,
        baseBonusMinutes: Int,
        bonusStepsPerBlock: Int,
        bonusMinutesPerBlock: Int,
        maxDailyBonusMinutes: Int
    ) {
        self.dailyStepGoal = max(0, dailyStepGoal)
        self.baseBonusMinutes = max(0, baseBonusMinutes)
        self.bonusStepsPerBlock = max(1, bonusStepsPerBlock)
        self.bonusMinutesPerBlock = max(0, bonusMinutesPerBlock)
        self.maxDailyBonusMinutes = max(0, maxDailyBonusMinutes)
    }
}

struct StepBonusState: Equatable {
    var totalGrantedMinutes: Int
    var baseBonusGranted: Bool
    var awardedExtraBlocks: Int
    var lastEvaluatedDay: Date

    init(totalGrantedMinutes: Int = 0, baseBonusGranted: Bool = false, awardedExtraBlocks: Int = 0, lastEvaluatedDay: Date = Date()) {
        self.totalGrantedMinutes = totalGrantedMinutes
        self.baseBonusGranted = baseBonusGranted
        self.awardedExtraBlocks = awardedExtraBlocks
        self.lastEvaluatedDay = lastEvaluatedDay
    }
}

struct StepBonusGrant: Equatable {
    let newlyEarnedMinutes: Int
    let updatedState: StepBonusState
}

struct StepBonusEngine: StepBonusCalculating {
    private let configuration: StepBonusConfiguration
    private let calendar: Calendar

    init(configuration: StepBonusConfiguration, calendar: Calendar = .current) {
        self.configuration = configuration
        self.calendar = calendar
    }

    func evaluate(steps: Int, day: Date, state: StepBonusState) -> StepBonusGrant {
        let sanitizedSteps = max(0, steps)
        let currentDay = calendar.startOfDay(for: day)
        var workingState = resetIfNeeded(state, for: currentDay)

        var newlyEarned = 0

        // Grant base bonus when the daily goal is reached for the first time
        if sanitizedSteps >= configuration.dailyStepGoal, !workingState.baseBonusGranted {
            let minutesToGrant = min(configuration.baseBonusMinutes, remainingMinutes(in: workingState))
            newlyEarned += minutesToGrant
            workingState.baseBonusGranted = true
            workingState.totalGrantedMinutes += minutesToGrant
        }

        // Grant extra blocks beyond the daily goal
        if sanitizedSteps > configuration.dailyStepGoal, configuration.bonusMinutesPerBlock > 0 {
            let extraSteps = sanitizedSteps - configuration.dailyStepGoal
            let blocks = extraSteps / configuration.bonusStepsPerBlock
            let newBlocks = max(0, blocks - workingState.awardedExtraBlocks)

            if newBlocks > 0 {
                let rawMinutes = newBlocks * configuration.bonusMinutesPerBlock
                let minutesToGrant = min(rawMinutes, remainingMinutes(in: workingState))
                let grantedBlocks = minutesToGrant / configuration.bonusMinutesPerBlock

                newlyEarned += minutesToGrant
                workingState.awardedExtraBlocks += grantedBlocks
                workingState.totalGrantedMinutes += minutesToGrant
            }
        }

        workingState.lastEvaluatedDay = currentDay

        return StepBonusGrant(
            newlyEarnedMinutes: newlyEarned,
            updatedState: workingState
        )
    }

    private func remainingMinutes(in state: StepBonusState) -> Int {
        max(0, configuration.maxDailyBonusMinutes - state.totalGrantedMinutes)
    }

    private func resetIfNeeded(_ state: StepBonusState, for currentDay: Date) -> StepBonusState {
        let previousDay = calendar.startOfDay(for: state.lastEvaluatedDay)
        guard previousDay == currentDay else {
            return StepBonusState(
                totalGrantedMinutes: 0,
                baseBonusGranted: false,
                awardedExtraBlocks: 0,
                lastEvaluatedDay: currentDay
            )
        }
        return state
    }
}
