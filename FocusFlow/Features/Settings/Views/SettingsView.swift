import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.colorScheme) private var colorScheme

    private let stepRange: ClosedRange<Double> = 2000...20000
    private let stepIncrement: Double = 500
    private let blockPresets: [Int] = [15, 25, 45, 60]

    var body: some View {
        ZStack {
            OnboardingTheme.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: OnboardingTheme.spacing) {
                    header
                    connectionStatusSection
                    stepGoalSection
                    dailyLimitSection
                    focusDurationSection
                    remindersSection
                    blockedAppsLink
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Sections
    private var header: some View {
        VStack(spacing: 8) {
            Text("Personalize your FocusFlow experience")
                .font(.title3.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text("Adjust your goals, limits, and notifications.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
    }

    private var connectionStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Connections")

            VStack(spacing: 12) {
                connectionRow(
                    icon: "heart.fill",
                    title: "Apple Health",
                    status: viewModel.healthStatusText,
                    color: viewModel.isHealthConnected ? .green : .orange
                )

                connectionRow(
                    icon: "hourglass.circle.fill",
                    title: "Screen Time",
                    status: viewModel.screenTimeStatusText,
                    color: viewModel.screenTimeStatusColor
                )
            }
            .padding(16)
            .background(cardBackground)
            .overlay(cardBorder)
        }
    }

    private var stepGoalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Daily step goal")

            Text("Set a realistic step goal to unlock extra screen time.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.7))

            VStack(alignment: .leading, spacing: 12) {
                Text("\(viewModel.stepGoal) steps")
                    .font(.title3.bold())
                    .foregroundColor(.white)

                Slider(
                    value: Binding(
                        get: { Double(viewModel.stepGoal) },
                        set: { viewModel.stepGoal = Int($0) }
                    ),
                    in: stepRange,
                    step: stepIncrement
                ) {
                    Text("Step Goal")
                } minimumValueLabel: {
                    Text("2k")
                        .font(.caption2)
                } maximumValueLabel: {
                    Text("20k")
                        .font(.caption2)
                }
                .tint(.accentColor)
            }
            .padding(16)
            .background(cardBackground)
            .overlay(cardBorder)
        }
    }

    private var dailyLimitSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Daily app limit")

            Text("Control how much distraction time you allow per day.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.7))

            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.formattedDailyLimit)
                    .font(.title3.bold())
                    .foregroundColor(.white)

                Slider(
                    value: Binding(
                        get: { Double(viewModel.dailyLimitMinutes) },
                        set: { viewModel.dailyLimitMinutes = Int($0) }
                    ),
                    in: 15...180,
                    step: 15
                ) {
                    Text("Daily Limit")
                } minimumValueLabel: {
                    Text("15m")
                        .font(.caption2)
                } maximumValueLabel: {
                    Text("3h")
                        .font(.caption2)
                }
                .tint(.accentColor)
            }
            .padding(16)
            .background(cardBackground)
            .overlay(cardBorder)
        }
    }

    private var focusDurationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Focus block duration")

            Text("Pick how long each focus session lasts by default.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.7))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(blockPresets, id: \.self) { preset in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.blockDurationMinutes = preset
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("\(preset) min")
                                .font(.subheadline)
                            if viewModel.blockDurationMinutes == preset {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption2)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    OnboardingTheme.chipBackground(
                                        isSelected: viewModel.blockDurationMinutes == preset,
                                        colorScheme: colorScheme
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    OnboardingTheme.chipBorder(
                                        isSelected: viewModel.blockDurationMinutes == preset,
                                        colorScheme: colorScheme
                                    ),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .background(cardBackground)
            .overlay(cardBorder)
        }
    }

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Notifications & haptics")

            VStack(spacing: 12) {
                Toggle(isOn: $viewModel.focusRemindersEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Focus reminders")
                            .font(.subheadline.bold())
                        Text("Get nudges to start or resume focus blocks.")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .tint(.accentColor)

                Toggle(isOn: $viewModel.focusHapticsEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Haptics")
                            .font(.subheadline.bold())
                        Text("Use subtle taps to signal focus events.")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .tint(.accentColor)
            }
            .padding(16)
            .background(cardBackground)
            .overlay(cardBorder)
        }
    }

    private var blockedAppsLink: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Blocked apps")

            NavigationLink(destination: BlockedAppsView()) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.12))
                            .frame(width: 44, height: 44)
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(OnboardingTheme.iconGradient)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Manage blocked apps")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                        Text("Update which apps are restricted during focus.")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(16)
                .background(cardBackground)
                .overlay(cardBorder)
            }
        }
    }

    // MARK: - Helpers
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.white)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: OnboardingTheme.cardCornerRadius, style: .continuous)
            .fill(OnboardingTheme.cardBackground(for: colorScheme))
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: OnboardingTheme.cardCornerRadius, style: .continuous)
            .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.12))
    }

    private func connectionRow(icon: String, title: String, status: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(OnboardingTheme.iconGradient)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Text(status)
                    .font(.footnote)
                    .foregroundColor(color.opacity(0.9))
            }

            Spacer()

            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                )
        }
    }
}
