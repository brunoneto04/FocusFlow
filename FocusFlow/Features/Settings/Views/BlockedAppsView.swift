//
//  BlockedAppsView.swift
//  FocusFlow
//
//  Created by formando on 09/12/2025.
//

import SwiftUI
import FamilyControls

struct BlockedAppsView: View {
    @StateObject private var viewModel = BlockedAppsViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Background gradient
            OnboardingTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Selected Apps Section
                    if viewModel.hasSelectedApps {
                        selectedAppsSection
                    }
                    
                    // Action Buttons
                    actionButtonsSection
                    
                    // Status Information
                    statusSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Blocked Apps")
        .navigationBarTitleDisplayMode(.large)
        .familyActivityPicker(
            isPresented: $viewModel.isPickerPresented,
            selection: $viewModel.screenTimeManager.selection
        )
        .onAppear {
            viewModel.checkAuthorizationStatus()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 80, height: 80)
                Circle()
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    .frame(width: 80, height: 80)
                Image(systemName: "hand.raised.circle.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(OnboardingTheme.iconGradient)
            }
            
            Text("Manage Blocked Apps")
                .font(.title2.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Select which apps to block during focus sessions")
                .foregroundColor(.white.opacity(0.8))
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Selected Apps Section
    private var selectedAppsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Selected Apps")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(viewModel.selectedAppsCount)")
                    .font(.subheadline.bold())
                    .foregroundColor(.white.opacity(0.8))
            }
            
            VStack(spacing: 12) {
                if viewModel.applicationTokens.isEmpty {
                    infoRow(icon: "app.dashed", text: "No apps selected")
                } else {
                    infoRow(
                        icon: "app.fill",
                        text: "\(viewModel.applicationTokens.count) app(s) selected"
                    )
                }

                if viewModel.categoryTokensCount == 0 {
                    infoRow(icon: "folder.dashed", text: "No categories selected")
                } else {
                    infoRow(
                        icon: "folder.fill",
                        text: "\(viewModel.categoryTokensCount) category(ies) selected"
                    )
                }

                if viewModel.webDomainTokensCount == 0 {
                    infoRow(icon: "globe", text: "No websites selected")
                } else {
                    infoRow(
                        icon: "globe",
                        text: "\(viewModel.webDomainTokensCount) website(s) selected"
                    )
                }

                if !viewModel.applicationTokens.isEmpty {
                    blockedApplicationsList
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
        }
    }

    private var blockedApplicationsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Aplicações bloqueadas")
                .font(.subheadline.bold())
                .foregroundColor(.white)

            ForEach(viewModel.applicationTokens, id: \.self) { token in
                blockedAppRow(name: viewModel.displayName(for: token))
            }
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Select Apps Button
            Button {
                viewModel.selectApps()
            } label: {
                HStack {
                    Image(systemName: "hand.tap.fill")
                    Text(viewModel.isAuthorized ? "Select Apps to Block" : "Enable Screen Time")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            
            if viewModel.hasSelectedApps {
                // Apply Block Button
                Button {
                    viewModel.applyBlock()
                } label: {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                        Text("Apply Block")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.bordered)
                .tint(.orange)
                .disabled(viewModel.isLoading)
                
                // Remove Block Button
                Button {
                    viewModel.removeBlock()
                } label: {
                    HStack {
                        Image(systemName: "lock.open.fill")
                        Text("Remove All Blocks")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .disabled(viewModel.isLoading)
            }
        }
    }
    
    // MARK: - Status Section
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Status")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 12) {
                statusRow(
                    title: "Authorization",
                    value: viewModel.authorizationStatusText,
                    color: viewModel.authorizationStatusColor
                )
                
                statusRow(
                    title: "Block Active",
                    value: viewModel.isBlockActive ? "Yes" : "No",
                    color: viewModel.isBlockActive ? .green : .gray
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Helper Views
    private func infoRow(icon: String, text: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
            Spacer()
        }
    }

    private func blockedAppRow(name: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "app.badge.checkmark")
                .foregroundColor(.white.opacity(0.85))
                .frame(width: 24)

            Text(name)
                .font(.subheadline)
                .foregroundColor(.white)

            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
    
    private func statusRow(title: String, value: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(color)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        BlockedAppsView()
    }
}
