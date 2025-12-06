//
//  FamilyActivityPicker.swift
//  FocusFlow
//
//  Created by formando on 27/11/2025.
//

import SwiftUI
import FamilyControls

struct ScreenTimeSetupView: View {
    @State private var isPickerPresented = false
    @State private var animateGlow: Bool = false
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Background gradient matching OnboardingView
            OnboardingTheme.backgroundGradient
                .ignoresSafeArea()
            
            // Animated glow background
            ScreenTimeSetupGlowBackground(isAnimating: animateGlow)
            
            ScrollView {
                VStack(spacing: OnboardingTheme.spacing) {
                    Spacer(minLength: 40)
                    
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Circle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            .frame(width: 80, height: 80)
                        Image(systemName: "hourglass.circle.fill")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(OnboardingTheme.iconGradient)
                    }
                    .padding(.bottom, 6)
                    
                    Text("Connect Screen Time")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Choose which apps and websites FocusFlow will manage.")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                    
                    Spacer(minLength: 20)
                    
                    Button {
                        Task {
                            do {
                                try await screenTimeManager.requestAuthorization()
                                isPickerPresented = true
                            } catch {
                                print("Screen Time authorization failed: \(error)")
                            }
                        }
                    } label: {
                        Text(labelForStatus())
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Block Select Apps") {
                        screenTimeManager.applySelectedShield()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Block All Apps") {
                        screenTimeManager.applyAllShield()
                    }
                    .buttonStyle(.bordered)
                    Button("Remove block") {
                        screenTimeManager.clearShield()
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Screen Time Setup")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            animateGlow = true
        }
        .familyActivityPicker(
            isPresented: $isPickerPresented,
            selection: $screenTimeManager.selection
        )
    }
    
    private func labelForStatus() -> String {
        switch screenTimeManager.authorizationStatus {
        case .approved:
            return "Choose apps and websites"
        case .denied:
            return "Screen Time access denied - open Settings"
        case .notDetermined:
            fallthrough
        @unknown default:
            return "Allow Screen Time access"
        }
    }
}

// MARK: - Screen Time Setup Glow Background
private struct ScreenTimeSetupGlowBackground: View {
    let isAnimating: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(OnboardingTheme.accentGradient)
                .frame(width: 320, height: 320)
                .blur(radius: 140)
                .scaleEffect(isAnimating ? 1.2 : 0.8)
                .offset(x: -120, y: -220)
                .opacity(0.6)
                .animation(OnboardingAnimation.glow, value: isAnimating)

            Circle()
                .fill(OnboardingTheme.accentGradient)
                .frame(width: 260, height: 260)
                .blur(radius: 120)
                .scaleEffect(isAnimating ? 1.05 : 0.85)
                .offset(x: 140, y: 200)
                .opacity(0.45)
                .animation(OnboardingAnimation.glow, value: isAnimating)
        }
    }
}
