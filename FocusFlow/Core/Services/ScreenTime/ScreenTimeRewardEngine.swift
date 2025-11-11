//
//  ScreenTimeRewardEngine.swift
//  FocusFlow
//
//  Created by formando on 11/11/2025.
//

import Foundation

struct ScreenTimeRewardConfig {
    let baseLimit: Int      // minutos base por dia
    let stepGoal: Int       // passos para bonus max
    let maxBonus: Int       // minutos extra max
}


struct ScreenTimeRewardEngine {
    // default config (podes tornar isto configurável mais tarde)
    static let `default` = ScreenTimeRewardEngine(
        config: ScreenTimeRewardConfig(
            baseLimit: 30,
            stepGoal: 10_000,
            maxBonus: 30
        )
    )

    let config: ScreenTimeRewardConfig

    func allowedMinutes(stepsToday: Int) -> Int {
        let progress = min(
            Double(stepsToday) / Double(config.stepGoal),
            1.0
        )

        let bonus = Int(progress * Double(config.maxBonus))
        return config.baseLimit + bonus
    }
}
