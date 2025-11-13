//
//  OnboardingView.swift
//  FocusFlow
//
//  Created by formando on 13/11/2025.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    
    @State private var isRequestingHealth = false
    @State private var healthError: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Bem-vindo ao FocusFlow")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text("Vamos ligar à app Saúde para transformar a tua atividade física em minutos extra de tempo de ecrã.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()

                Button {
                    requestHealthPermission()
                } label: {
                    Text(isRequestingHealth ? "A pedir autorização..." : "Permitir acesso à Saúde")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isRequestingHealth)

                if let healthError {
                    Text(healthError)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button("Continuar sem ligar à Saúde") {
                    onFinish()
                }
                .font(.footnote)
                .padding(.top, 8)

                Spacer()
            }
            .padding()
        }
    }

    private func requestHealthPermission() {
        isRequestingHealth = true
        healthError = nil

        HealthKitManager.shared.requestAuthorization { success in
            isRequestingHealth = false
            if success {
                onFinish()
            } else {
                healthError = "Não foi possível ativar o acesso. Podes alterar isto mais tarde nas Definições."
            }
        }
    }
}
