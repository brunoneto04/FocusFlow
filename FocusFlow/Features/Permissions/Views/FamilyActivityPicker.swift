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
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Connect Screen Time")
                .font(.title.bold())
                .multilineTextAlignment(.center)
            
            Text("Choose which apps and websites FocusFlow will manage.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
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
            
            Button("Test block now") {
                screenTimeManager.applyShield()
            }
            .buttonStyle(.bordered)
            
            Button("Remove block") {
                screenTimeManager.clearShield()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        // Picker oficial da Apple
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
