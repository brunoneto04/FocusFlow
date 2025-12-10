//
//  BlockedAppsViewModel.swift
//  FocusFlow
//
//  Created by formando on 09/12/2025.
//

import Foundation
import SwiftUI
import Combine
import FamilyControls

@MainActor
final class BlockedAppsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isPickerPresented = false
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isBlockActive = false
    
    // MARK: - Dependencies
    @ObservedObject private(set) var screenTimeManager = ScreenTimeManager.shared
    
    // MARK: - Computed Properties
    var isAuthorized: Bool {
        screenTimeManager.authorizationStatus == .approved
    }
    
    var hasSelectedApps: Bool {
        !screenTimeManager.selection.applicationTokens.isEmpty ||
        !screenTimeManager.selection.categoryTokens.isEmpty ||
        !screenTimeManager.selection.webDomainTokens.isEmpty
    }

    var selectedAppsCount: Int {
        screenTimeManager.selection.applicationTokens.count +
        screenTimeManager.selection.categoryTokens.count +
        screenTimeManager.selection.webDomainTokens.count
    }

    var applicationTokens: [ApplicationToken] {
        screenTimeManager.selection.applicationTokens
            .sorted { $0.bundleIdentifier < $1.bundleIdentifier }
    }

    var categoryTokensCount: Int {
        screenTimeManager.selection.categoryTokens.count
    }

    var webDomainTokensCount: Int {
        screenTimeManager.selection.webDomainTokens.count
    }
    
    var authorizationStatusText: String {
        switch screenTimeManager.authorizationStatus {
        case .notDetermined:
            return "Not Requested"
        case .denied:
            return "Denied"
        case .approved:
            return "Approved"
        @unknown default:
            return "Unknown"
        }
    }
    
    var authorizationStatusColor: Color {
        switch screenTimeManager.authorizationStatus {
        case .approved:
            return .green
        case .denied:
            return .red
        case .notDetermined:
            return .orange
        @unknown default:
            return .gray
        }
    }
    
    // MARK: - Initialization
    init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Methods
    func checkAuthorizationStatus() {
        // Update authorization status
        screenTimeManager.authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }
    
    func selectApps() {
        guard !isLoading else { return }
        
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                if !isAuthorized {
                    try await screenTimeManager.requestAuthorization()
                    checkAuthorizationStatus()
                }
                
                if isAuthorized {
                    isPickerPresented = true
                } else {
                    showErrorMessage("Screen Time authorization was denied. Please enable it in Settings.")
                }
            } catch {
                showErrorMessage("Failed to request Screen Time authorization: \(error.localizedDescription)")
            }
        }
    }
    
    func applyBlock() {
        guard !isLoading else { return }
        guard hasSelectedApps else {
            showErrorMessage("No apps selected. Please select apps first.")
            return
        }
        
        isLoading = true
        
        Task {
            defer { isLoading = false }
            
            do {
                screenTimeManager.applySelectedShield()
                isBlockActive = true
                
                // Show success feedback (you can add a success message here)
                print("Block applied successfully")
            } catch {
                showErrorMessage("Failed to apply block: \(error.localizedDescription)")
            }
        }
    }
    
    func removeBlock() {
        guard !isLoading else { return }
        
        isLoading = true
        
        Task {
            defer { isLoading = false }
            
            do {
                screenTimeManager.clearShield()
                isBlockActive = false
                
                // Show success feedback
                print("Block removed successfully")
            } catch {
                showErrorMessage("Failed to remove block: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private Methods
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }

    func displayName(for token: ApplicationToken) -> String {
        token.bundleIdentifier
    }
}
