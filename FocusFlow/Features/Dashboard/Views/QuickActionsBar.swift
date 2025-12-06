import SwiftUI

struct QuickActionsBar: View {
    let isFocusing: Bool
    let onFocus: () -> Void
    let onStop: () -> Void
    let onBreak: () -> Void
    let onPlanner: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            if isFocusing {
                Button {
                    onBreak()
                } label: {
                    Label("Break 5m", systemImage: "pause.circle")
                }
                .buttonStyle(.bordered)

                Button(role: .destructive) {
                    onStop()
                } label: {
                    Label("Stop Focus", systemImage: "stop.circle")
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button {
                    onFocus()
                } label: {
                    Label("Focus Now", systemImage: "bolt.fill")
                }
                .buttonStyle(.borderedProminent)
            }

            Button {
                onPlanner()
            } label: {
                Label("Open Planner", systemImage: "calendar")
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        .accessibilityElement(children: .contain)
    }
}
