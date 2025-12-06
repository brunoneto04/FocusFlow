//
//  PermissionCard.swift
//  FocusFlow
//
//  Created by formando on 27/11/2025.
//


import SwiftUI

struct PermissionCard: View {
    let systemImage: String
    let title: String
    let subtitle: String
    let buttonTitle: String
    let isLoading: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: OnboardingTheme.spacing) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 50, height: 50)
                    Circle()
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        .frame(width: 50, height: 50)
                    Image(systemName: systemImage)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(OnboardingTheme.iconGradient)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            Button(action: action) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(buttonTitle)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
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
    }
}
