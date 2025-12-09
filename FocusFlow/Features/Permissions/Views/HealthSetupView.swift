import SwiftUI
import HealthKit

struct HealthSetupView: View {
    let onFinish: () -> Void
    
    @State private var isRequestingHealth = false
    @State private var healthError: String?
    @State private var previewSteps: Int? = nil
    @State private var animateGlow: Bool = false
    
    @AppStorage("isHealthConnected") private var isHealthConnected: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Background gradient matching OnboardingView
            OnboardingTheme.backgroundGradient
                .ignoresSafeArea()
            
            // Animated glow background
            HealthSetupGlowBackground(isAnimating: animateGlow)
            
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
                        Image(systemName: "heart.fill")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(OnboardingTheme.iconGradient)
                    }
                    .padding(.bottom, 6)
                    
                    Text("Connect Apple Health")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("We use your step count from Apple Health to turn your movement into extra screen time. We don't access any medical records.")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("We will read:")
                            .font(.footnote.bold())
                            .foregroundColor(.primary)
                        
                        Label("Step count", systemImage: "shoeprints.fill")
                            .font(.footnote)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(OnboardingTheme.cardBackground(for: colorScheme))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.12))
                            )
                    )
                    .shadow(color: OnboardingTheme.shadow, radius: 10, x: 0, y: 5)

                    if let previewSteps {
                        HStack(spacing: 6) {
                            Image(systemName: "figure.walk")
                            Text("Steps today: \(previewSteps)")
                        }
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer(minLength: 20)
                    
                    Button {
                        requestHealthPermission()
                    } label: {
                        HStack {
                            if isRequestingHealth {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(isRequestingHealth ? "Requesting permission..." : "Allow access in Apple Health")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isRequestingHealth)
                    
                    if let healthError {
                        Text(healthError)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                    
                    Button("Continue without Health") {
                        onFinish()
                    }
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 4)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Health Setup")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            animateGlow = true
        }
    }
    
    private func requestHealthPermission() {
        if !HKHealthStore.isHealthDataAvailable() {
            healthError = "Apple Health is not available on this device."
            return
        }
        
        isRequestingHealth = true
        healthError = nil
        
        Task {
            let success = await HealthKitManager.shared.requestAuthorization()
            
            await MainActor.run {
                isRequestingHealth = false
                
                if success {
                    isHealthConnected = true
                    HealthKitManager.shared.fetchTodaySteps { steps in
                        previewSteps = steps
                        onFinish()
                    }
                } else {
                    healthError = "We couldn't enable Health access. You can change this later in Settings."
                }
            }
        }
    }
}

// MARK: - Health Setup Glow Background
private struct HealthSetupGlowBackground: View {
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
