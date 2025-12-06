import SwiftUI

struct TodayProgressSection: View {
    let health: HealthProgress
    
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 16) {
            ProgressRing(progress: health.progress) {
                AnyView(
                    VStack(spacing: 2) {
                        Text("\(Int(health.progress * 100))%")
                            .font(.title2).bold()
                        Text("today").font(.caption).foregroundStyle(.secondary)
                    }
                )
            }
            .frame(width: 120, height: 120)

            VStack(alignment: .leading, spacing: 6) {
                Text(health.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(health.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Keep going — you're close!")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
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
        .accessibilityLabel("\(health.title). \(health.detail).")
    }
}
