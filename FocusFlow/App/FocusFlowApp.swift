import SwiftUI
import Combine
@main
struct FocusFlowApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding{
                RootView()
            }
            else{
                OnboardingView()
            }
            
        }
    }
}

