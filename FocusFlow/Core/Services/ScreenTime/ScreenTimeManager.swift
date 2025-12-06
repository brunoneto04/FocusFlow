//
//  ScreenTimeManger.swift
//  FocusFlow
//
//  Created by formando on 27/11/2025.
//

import Foundation
import Combine
import FamilyControls
import ManagedSettings

@MainActor
final class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()
    
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var selection = FamilyActivitySelection()
    
    let store = ManagedSettingsStore()
    
    private init() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }
    
    func requestAuthorization() async throws {
        let center = AuthorizationCenter.shared
        try await center.requestAuthorization(for: .individual)
        authorizationStatus = center.authorizationStatus
    }
    
    func applySelectedShield() {
        // Exemplo simples: bloquear tudo o que estiver na seleção
        store.shield.applications = selection.applicationTokens
        store.shield.webDomains = selection.webDomainTokens
    }
    func applyAllShield() {
        // Exemplo simples: bloquear tudo o que estiver na seleção
        store.shield.applicationCategories = .all()
        store.shield.webDomainCategories = .all()
    }
    
    func clearShield() {
        store.clearAllSettings()
    }
}

