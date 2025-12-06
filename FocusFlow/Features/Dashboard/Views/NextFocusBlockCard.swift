import SwiftUI
import Combine

struct NextFocusBlockCard: View {
    let block: FocusBlock?
    
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Next Focus Block", systemImage: "calendar.badge.clock")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }

            if let block {
                Text(block.title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text("\(timeRange(block.start, block.end)) • \(block.durationMinutes) min")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Text("No upcoming focus blocks.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
        .accessibilityLabel(block != nil
            ? "Next focus block \(block!.title) at \(timeRange(block!.start, block!.end))"
            : "No upcoming focus blocks")
    }

    private func timeRange(_ start: Date, _ end: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return "\(f.string(from: start)) – \(f.string(from: end))"
    }
}
