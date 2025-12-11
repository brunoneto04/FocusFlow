import SwiftUI

struct UsageSummaryCard: View {
    let usage: UsageSummary
   
    
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Screen Time (Today)", systemImage: "hourglass")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }

            ProgressView(value: progressValue)
                .progressViewStyle(.linear)
                .tint(.accentColor)

            HStack {
                Text(summaryLine)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
                
            }
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
        .accessibilityLabel("Screen Time today \(summaryLine)")
    }

    private var progressValue: Double {
        guard let limit = usage.limitMinutes, limit > 0 else { return 0 }
        return min(1.0, Double(usage.usedMinutes) / Double(limit))
    }

    private var summaryLine: String {
        if let limit = usage.limitMinutes {
            return "\(usage.usedMinutes)m / \(limit)m"
        }
        return "\(usage.usedMinutes)m"
    }
}
