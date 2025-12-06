import SwiftUI

struct PermissionBanner: View {
    let missing: [PermissionKind]
    let onGrant: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.yellow)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Permissions needed")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(missing.map { $0.displayName }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Grant", action: onGrant)
                .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: OnboardingTheme.cardCornerRadius, style: .continuous)
                .fill(OnboardingTheme.cardBackground(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: OnboardingTheme.cardCornerRadius, style: .continuous)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 2)
                )
        )
        .shadow(color: OnboardingTheme.shadow, radius: 20, x: 0, y: 10)
        .accessibilityLabel("Permissions needed: \(missing.map{$0.displayName}.joined(separator: ", "))")
    }
}
