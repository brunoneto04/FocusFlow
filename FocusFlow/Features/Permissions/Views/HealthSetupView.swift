import SwiftUI
import HealthKit

struct HealthSetupView: View {
    let onFinish: () -> Void
    
    @State private var isRequestingHealth = false
    @State private var healthError: String?
    @State private var previewSteps: Int? = nil
    
    @AppStorage("isHealthConnected") private var isHealthConnected: Bool = false  // 👈 novo

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                    .padding(.top, 8)
                
                Text("Connect Apple Health")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                
                Text("We use your step count from Apple Health to turn your movement into extra screen time. We don’t access any medical records.")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("We will read:")
                        .font(.footnote.bold())
                    
                    Label("Step count", systemImage: "shoeprints.fill")
                        .font(.footnote)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )

                if let previewSteps {
                    HStack(spacing: 6) {
                        Image(systemName: "figure.walk")
                        Text("Steps today: \(previewSteps)")
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    requestHealthPermission()
                } label: {
                    Text(isRequestingHealth ? "Requesting permission..." : "Allow access in Apple Health")
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
                .padding(.top, 4)
                
                Spacer(minLength: 8)
            }
            .padding()
            .navigationBarTitle("Health setup", displayMode: .inline)
        }
    }
    
    private func requestHealthPermission() {
        // Se tiveres isHealthAvailable no manager:
        if !HKHealthStore.isHealthDataAvailable() {
            healthError = "Apple Health is not available on this device."
            return
        }
        
        isRequestingHealth = true
        healthError = nil
        
        HealthKitManager.shared.requestAuthorization { success in
            isRequestingHealth = false
            
            if success {
                isHealthConnected = true
                HealthKitManager.shared.fetchTodaySteps { steps in
                    previewSteps = steps
                    // Se aqui quiseres só fechar logo:
                    onFinish()
                }
            } else {
                healthError = "We couldn’t enable Health access. You can change this later in Settings."
            }
        }
    }
}
