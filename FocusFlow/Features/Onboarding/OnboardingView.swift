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
    @State private var dailyLimitMinutes: Int = 90 // 1h30 by default
    @State private var isGoingForward: Bool = true
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer(minLength: 0)
                
                ZStack {
                    contentForCurrentStep()
                        .id(step)
                        .offset(x: dragOffset.width, y: 0)
                        .transition(
                            isGoingForward
                            ? .asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                              )
                            : .asymmetric(
                                insertion: .move(edge: .leading),
                                removal: .move(edge: .trailing)
                              )
                        )
                }
                .animation(.easeInOut, value: step)
                
                Spacer(minLength: 8)
                
                progressDots
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .navigationBarHidden(true)
            .contentShape(Rectangle()) // swipe em todo o ecrã
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 80
                        
                        if value.translation.width < -threshold {
                            goToNextStep()
                        } else if value.translation.width > threshold {
                            goToPreviousStep()
                        }
                        
                        dragOffset = .zero
                    }
            )
        }
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
        HStack(spacing: 6) {
            ForEach(0..<5) { index in
                Circle()
                    .frame(width: 7, height: 7)
                    .opacity(step.rawValue == index ? 1.0 : 0.3)
            }
        }
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
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 26, weight: .semibold))
                .padding(.top, 8)
            
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
            
            Spacer(minLength: 16)
            
            Text("Swipe left to continue")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}

// 2. How it works
struct OnboardingHowItWorksStep: View {
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "hand.tap")
                .font(.system(size: 26, weight: .semibold))
                .padding(.top, 8)
            
            Text("How FocusFlow works")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            VStack(alignment: .leading, spacing: 10) {
                Label {
                    Text("You set a daily screen time limit for distracting apps.")
                } icon: {
                    Image(systemName: "1.circle.fill")
                }
                
                Label {
                    Text("When you reach the limit, those apps are paused.")
                } icon: {
                    Image(systemName: "2.circle.fill")
                }
                
                Label {
                    Text("You earn extra time by moving, using your data from Apple Health.")
                } icon: {
                    Image(systemName: "3.circle.fill")
                }
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 16)
            
            Text("Swipe left or right to navigate")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}

// 3. Goal selection
struct OnboardingGoalStep: View {
    @Binding var selectedGoal: UserGoal
    
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "target")
                .font(.system(size: 26, weight: .semibold))
                .padding(.top, 8)
            
            Text("What’s your main goal?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            VStack(spacing: 10) {
                ForEach(UserGoal.allCases) { goal in
                    Button {
                        selectedGoal = goal
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
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedGoal == goal
                                      ? Color.accentColor.opacity(0.15)
                                      : Color(.secondarySystemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selectedGoal == goal
                                        ? Color.accentColor
                                        : Color.gray.opacity(0.2),
                                        lineWidth: 1)
                        )
                    }
                }
            }
            
            Spacer(minLength: 16)
            
            Text("Tap to select, then swipe")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}

// 4. Daily limit – chips + slider (user-friendly)
struct OnboardingDailyLimitStep: View {
    @Binding var dailyLimitMinutes: Int
    
    @State private var sliderValue: Double = 90
    private let presets: [Int] = [30, 60, 90, 120] // minutes
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "timer")
                .font(.system(size: 26, weight: .semibold))
                .padding(.top, 8)
            
            Text("How much distraction time per day feels reasonable?")
                .font(.headline.bold())
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 24)
            
            Text(formattedLimit)
                .font(.system(size: 30, weight: .bold, design: .rounded))
            
            // Presets
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick options")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(presets, id: \.self) { value in
                        Button {
                            sliderValue = Double(value)
                            dailyLimitMinutes = value
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
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(dailyLimitMinutes == value
                                          ? Color.accentColor.opacity(0.18)
                                          : Color(.secondarySystemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(dailyLimitMinutes == value
                                            ? Color.accentColor
                                            : Color.gray.opacity(0.2),
                                            lineWidth: 1)
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
            
            // Slider
            VStack(spacing: 8) {
                Slider(
                    value: $sliderValue,
                    in: 15...180,
                    step: 15
                ) {
                    Text("Daily limit")
                } minimumValueLabel: {
                    Text("15m")
                        .font(.caption2)
                } maximumValueLabel: {
                    Text("3h")
                        .font(.caption2)
                }
                .onChange(of: sliderValue) { newVal in
                    dailyLimitMinutes = Int(newVal)
                }
                
                Text("Use the quick options or adjust the slider.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
            
            Text("You can change this later in Settings.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Spacer(minLength: 8)
            
            Text("Set your limit, then swipe")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
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
        VStack(spacing: 18) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 26, weight: .semibold))
                .padding(.top, 8)
            
            Text("You’re all set to start")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            VStack(alignment: .leading, spacing: 10) {
                Label {
                    Text("Goal: \(userGoal.rawValue)")
                } icon: {
                    Image(systemName: "target")
                }
                
                Label {
                    Text("Daily distraction time: \(formattedLimit)")
                } icon: {
                    Image(systemName: "clock")
                }
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
                .padding(.vertical, 6)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Next steps to unlock the full experience:")
                    .font(.subheadline)
                
                Label("Connect Apple Health to earn extra time", systemImage: "heart.fill")
                Label("Enable Screen Time controls to pause apps", systemImage: "iphone")
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 16)
            
            Button {
                onFinish()
            } label: {
                Text("Go to dashboard")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
