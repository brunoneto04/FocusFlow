//
//  OnboardingView.swift
//  FocusFlow
//
//  Created by formando on 13/11/2025.
//

import SwiftUI
import Foundation

// MARK: - Models

enum UserGoal: String, CaseIterable, Identifiable {
    case studyLessDistracted = "Study with fewer distractions"
    case reduceSocialMedia = "Reduce social media time"
    case sleepBetter = "Sleep better"
    case justCurious = "Just curious / Other"
    
    var id: String { rawValue }
}

private enum OnboardingStep: Int {
    case welcome
    case howItWorks
    case goal
    case dailyLimit
    case summary
}

// MARK: - Root Onboarding View

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("userGoal") private var storedUserGoal: String = ""
    @AppStorage("dailyLimitMinutes") private var storedDailyLimitMinutes: Int = 90

    @State private var step: OnboardingStep = .welcome
    @State private var userGoal: UserGoal = .studyLessDistracted
    @State private var dailyLimitMinutes: Int = 90
    @State private var isGoingForward: Bool = true
    @State private var dragOffset: CGSize = .zero
    @State private var animateGlow: Bool = false
    @Namespace private var stepNamespace

    var body: some View {
        NavigationStack {
            ZStack {
                OnboardingTheme.backgroundGradient
                    .ignoresSafeArea()

                OnboardingGlowBackground(isAnimating: animateGlow)

                VStack(spacing: 28) {
                    Spacer(minLength: 0)

                    OnboardingStepCard(namespace: stepNamespace) {
                        contentForCurrentStep()
                            .id(step)
                            .transition(stepTransition)
                    }
                    .offset(x: dragOffset.width)
                    .animation(OnboardingAnimation.card, value: step)

                    Spacer(minLength: 0)

                    progressDots
                        .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 32)
                .toolbar(.hidden, for: .navigationBar)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 80

                            if value.translation.width < -threshold {
                                withAnimation(OnboardingAnimation.card) {
                                    goToNextStep()
                                }
                            } else if value.translation.width > threshold {
                                withAnimation(OnboardingAnimation.card) {
                                    goToPreviousStep()
                                }
                            }

                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                dragOffset = .zero
                            }
                        }
                )
            }
            .onAppear {
                animateGlow = true
            }
        }
    }

    private var stepTransition: AnyTransition {
        let insertionEdge: Edge = isGoingForward ? .trailing : .leading
        let removalEdge: Edge = isGoingForward ? .leading : .trailing

        return .asymmetric(
            insertion: .move(edge: insertionEdge).combined(with: .opacity),
            removal: .move(edge: removalEdge).combined(with: .opacity)
        )
    }

    // MARK: - Step content
    
    @ViewBuilder
    private func contentForCurrentStep() -> some View {
        switch step {
        case .welcome:
            OnboardingWelcomeStep()
            
        case .howItWorks:
            OnboardingHowItWorksStep()
            
        case .goal:
            OnboardingGoalStep(selectedGoal: $userGoal)
            
        case .dailyLimit:
            OnboardingDailyLimitStep(dailyLimitMinutes: $dailyLimitMinutes)
            
        case .summary:
            OnboardingSummaryStep(
                userGoal: userGoal,
                dailyLimitMinutes: dailyLimitMinutes,
                onFinish: completeOnboarding
            )
        }
    }
    
    // MARK: - Footer progress
    
    private var progressDots: some View {
        HStack(spacing: 10) {
            ForEach(0..<5, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(step.rawValue >= index ? 0.95 : 0.35))
                    .frame(width: step.rawValue == index ? 22 : 8, height: 6)
                    .scaleEffect(step.rawValue == index ? 1.1 : 1.0)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.08), in: Capsule(style: .continuous))
        .animation(OnboardingAnimation.progress, value: step)
    }
    
    // MARK: - Navigation helpers
    
    private func goToNextStep() {
        isGoingForward = true
        switch step {
        case .welcome: step = .howItWorks
        case .howItWorks: step = .goal
        case .goal: step = .dailyLimit
        case .dailyLimit: step = .summary
        case .summary: break
        }
    }
    
    private func goToPreviousStep() {
        isGoingForward = false
        switch step {
        case .welcome: break
        case .howItWorks: step = .welcome
        case .goal: step = .howItWorks
        case .dailyLimit: step = .goal
        case .summary: step = .dailyLimit
        }
    }
    
    private func completeOnboarding() {
        storedUserGoal = userGoal.rawValue
        storedDailyLimitMinutes = dailyLimitMinutes
        hasCompletedOnboarding = true
    }
}

//////////////////////////////////////////////////////////
// MARK: - Step subviews (small-screen friendly)
//////////////////////////////////////////////////////////

// 1. Welcome
struct OnboardingWelcomeStep: View {
    var body: some View {
        VStack(spacing: OnboardingTheme.spacing) {
            OnboardingIcon(systemName: "sparkles")

            Text("Welcome to FocusFlow")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text("Turn your physical activity into extra screen time and make your phone work for you, not against you.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            Text("Swipe left to continue")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// 2. How it works
struct OnboardingHowItWorksStep: View {
    var body: some View {
        VStack(spacing: OnboardingTheme.spacing) {
            OnboardingIcon(systemName: "hand.tap")

            Text("How FocusFlow works")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            VStack(alignment: .leading, spacing: 12) {
                OnboardingBullet(index: 1, text: "You set a daily screen time limit for distracting apps.")
                OnboardingBullet(index: 2, text: "When you reach the limit, those apps are paused.")
                OnboardingBullet(index: 3, text: "You earn extra time by moving, using your data from Apple Health.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("Swipe left or right to navigate")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// 3. Goal selection
struct OnboardingGoalStep: View {
    @Binding var selectedGoal: UserGoal
    @SwiftUI.Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: OnboardingTheme.spacing) {
            OnboardingIcon(systemName: "target")

            Text("What’s your main goal?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            VStack(spacing: 12) {
                ForEach(UserGoal.allCases) { goal in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedGoal = goal
                        }
                    } label: {
                        HStack {
                            Text(goal.rawValue)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if goal == selectedGoal {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(OnboardingTheme.chipBackground(isSelected: goal == selectedGoal, colorScheme: colorScheme))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(OnboardingTheme.chipBorder(isSelected: goal == selectedGoal, colorScheme: colorScheme), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("Tap to select, then swipe")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// 4. Daily limit – chips + slider
struct OnboardingDailyLimitStep: View {
    @Binding var dailyLimitMinutes: Int
    @State private var sliderValue: Double = 90
    private let presets: [Int] = [30, 60, 90, 120]
        @SwiftUI.Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: OnboardingTheme.spacing) {
            OnboardingIcon(systemName: "timer")

            Text("How much distraction time per day feels reasonable?")
                .font(.headline.bold())
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 12)

            Text(formattedLimit)
                .font(.system(size: 34, weight: .bold, design: .rounded))

            VStack(alignment: .leading, spacing: 8) {
                Text("Quick options")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(presets, id: \.self) { value in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                sliderValue = Double(value)
                                dailyLimitMinutes = value
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(label(for: value))
                                    .font(.subheadline)
                                if dailyLimitMinutes == value {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption2)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(OnboardingTheme.chipBackground(isSelected: dailyLimitMinutes == value, colorScheme: colorScheme))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(OnboardingTheme.chipBorder(isSelected: dailyLimitMinutes == value, colorScheme: colorScheme), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            VStack(spacing: 10) {
                Slider(value: $sliderValue, in: 15...180, step: 15) {
                    Text("Daily limit")
                } minimumValueLabel: {
                    Text("15m")
                        .font(.caption2)
                } maximumValueLabel: {
                    Text("3h")
                        .font(.caption2)
                }
                .tint(.accentColor)
                .onChange(of: sliderValue) { newValue in
                    dailyLimitMinutes = Int(newValue)
                }

                Text("Use the quick options or adjust the slider.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Text("You can change this later in Settings.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text("Set your limit, then swipe")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .onAppear {
            sliderValue = Double(dailyLimitMinutes)
            if sliderValue < 15 || sliderValue > 180 {
                sliderValue = 90
            }
            dailyLimitMinutes = Int(sliderValue)
        }
    }

    // Helpers
    private var formattedLimit: String {
        let hours = dailyLimitMinutes / 60
        let minutes = dailyLimitMinutes % 60
        
        if hours == 0 {
            return "\(minutes) min"
        } else if minutes == 0 {
            return "\(hours) h"
        } else {
            return "\(hours) h \(minutes) min"
        }
    }
    
    private func label(for value: Int) -> String {
        let h = value / 60
        let m = value % 60
        
        if h == 0 { return "\(m) min" }
        if m == 0 { return "\(h) h" }
        return "\(h) h \(m) min"
    }
}

// 5. Summary
struct OnboardingSummaryStep: View {
    let userGoal: UserGoal
    let dailyLimitMinutes: Int
    let onFinish: () -> Void

    private var formattedLimit: String {
        let hours = dailyLimitMinutes / 60
        let minutes = dailyLimitMinutes % 60

        if hours == 0 {
            return "\(minutes) min"
        } else if minutes == 0 {
            return "\(hours) h"
        } else {
            return "\(hours) h \(minutes) min"
        }
    }

    var body: some View {
        VStack(spacing: OnboardingTheme.spacing) {
            OnboardingIcon(systemName: "checkmark.seal.fill")

            Text("You’re all set to start")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            VStack(alignment: .leading, spacing: 12) {
                Label { Text("Goal: \(userGoal.rawValue)") } icon: { Image(systemName: "target") }
                Label { Text("Daily distraction time: \(formattedLimit)") } icon: { Image(systemName: "clock") }
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                Text("Next steps to unlock the full experience:")
                    .font(.subheadline)
                Label("Connect Apple Health to earn extra time", systemImage: "heart.fill")
                Label("Enable Screen Time controls to pause apps", systemImage: "iphone")
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                onFinish()
            } label: {
                Text("Go to dashboard")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Reusable views
private struct OnboardingStepCard<Content: View>: View {
        @SwiftUI.Environment(\.colorScheme) private var colorScheme
    private let content: () -> Content
    let namespace: Namespace.ID

    init(namespace: Namespace.ID, @ViewBuilder content: @escaping () -> Content) {
        self.namespace = namespace
        self.content = content
    }

    var body: some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 32)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: OnboardingTheme.cardCornerRadius, style: .continuous)
                    .fill(OnboardingTheme.cardBackground(for: colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: OnboardingTheme.cardCornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.12))
                    )
                    .matchedGeometryEffect(id: "cardBackground", in: namespace)
                    .shadow(color: OnboardingTheme.shadow, radius: 40, x: 0, y: 25)
            )
    }
}

private struct OnboardingIcon: View {
    let systemName: String

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 60, height: 60)
            Circle()
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                .frame(width: 60, height: 60)
            Image(systemName: systemName)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(OnboardingTheme.iconGradient)
        }
        .padding(.bottom, 6)
    }
}

private struct OnboardingBullet: View {
    let index: Int
    let text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text("\(index)")
                .font(.subheadline.bold())
                .frame(width: 26, height: 26)
                .background(Color.white.opacity(0.12), in: Circle())
            Text(text)
                .font(.subheadline)
        }
        .foregroundColor(.primary)
    }
}

private struct OnboardingGlowBackground: View {
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
