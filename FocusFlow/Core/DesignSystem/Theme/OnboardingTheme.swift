import SwiftUI

enum OnboardingTheme {
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.08, green: 0.11, blue: 0.24),
            Color(red: 0.01, green: 0.02, blue: 0.07)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [
            Color.accentColor.opacity(0.9),
            Color.accentColor.opacity(0.6)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let iconGradient = LinearGradient(
        colors: [
            Color.accentColor,
            Color.accentColor.opacity(0.7)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardCornerRadius: CGFloat = 28
    static let spacing: CGFloat = 18
    static let shadow = Color.black.opacity(0.2)

    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
        ? Color.white.opacity(0.08)
        : Color.white.opacity(0.9)
    }

    static func chipBackground(isSelected: Bool, colorScheme: ColorScheme) -> Color {
        if isSelected {
            return colorScheme == .dark
            ? Color.accentColor.opacity(0.35)
            : Color.accentColor.opacity(0.18)
        }

        return Color(.secondarySystemBackground)
    }

    static func chipBorder(isSelected: Bool, colorScheme: ColorScheme) -> Color {
        if isSelected { return Color.accentColor }
        return Color.gray.opacity(colorScheme == .dark ? 0.35 : 0.2)
    }
}

enum OnboardingAnimation {
    static let card = Animation.spring(response: 0.5, dampingFraction: 0.85, blendDuration: 0.2)
    static let progress = Animation.easeInOut(duration: 0.25)
    static let glow = Animation.easeInOut(duration: 6).repeatForever(autoreverses: true)
}
