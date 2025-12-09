import SwiftUI

struct ActivityBonusCard: View {
    @ObservedObject var orchestrator: ActivityBonusOrchestrator
    let configuration: StepBonusConfiguration

    @Environment(\.colorScheme) private var colorScheme

    private var stepProgress: Double {
        guard configuration.dailyStepGoal > 0 else { return 0 }
        return min(Double(orchestrator.lastKnownSteps) / Double(configuration.dailyStepGoal), 1.0)
    }

    private var stepsDetail: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let steps = formatter.string(from: NSNumber(value: orchestrator.lastKnownSteps)) ?? "\(orchestrator.lastKnownSteps)"
        let goal = formatter.string(from: NSNumber(value: configuration.dailyStepGoal)) ?? "\(configuration.dailyStepGoal)"
        return "\(steps) / \(goal) steps"
    }

    private var canRedeem: Bool {
        orchestrator.blockedGroupIdentifier != nil && orchestrator.availableBonusMinutes > 0 && orchestrator.activeUnlockUntil == nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Activity unlocks")
                        .font(.headline)
                    Text("Walk to earn more time for your blocked apps.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                ProgressRing(progress: stepProgress) {
                    AnyView(
                        VStack(spacing: 2) {
                            Text("\(Int(stepProgress * 100))%")
                                .font(.title3).bold()
                            Text("goal")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    )
                }
                .frame(width: 80, height: 80)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(stepsDetail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(statusLine)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Available bonus")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(orchestrator.availableBonusMinutes) min")
                        .font(.title3).bold()
                }
                Spacer()
                if let deadline = orchestrator.activeUnlockUntil {
                    Label("Unlocked until \(deadline.formatted(date: .omitted, time: .shortened))", systemImage: "hourglass")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                }
            }

            Button {
                orchestrator.startBonusSession(minutes: 5)
            } label: {
                Text(canRedeem ? "Unlock 5 minutes" : "Waiting for steps")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canRedeem)

            Button {
                Task { await orchestrator.refreshStepsAndBonus() }
            } label: {
                Label("Refresh steps", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: OnboardingTheme.cardCornerRadius, style: .continuous)
                .fill(OnboardingTheme.cardBackground(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: OnboardingTheme.cardCornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.12))
                )
        )
        .shadow(color: OnboardingTheme.shadow, radius: 20, x: 0, y: 10)
        .accessibilityElement(children: .combine)
    }

    private var statusLine: String {
        if orchestrator.activeUnlockUntil != nil {
            return "Bonus time currently active."
        }

        if let blocked = orchestrator.blockedGroupIdentifier {
            return "\(blocked) is blocked. Walk to unlock more time."
        }

        return "You're within your limit. Keep steps coming to earn backup time."
    }
}
