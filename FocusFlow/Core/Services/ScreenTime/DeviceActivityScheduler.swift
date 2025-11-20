import Foundation
import FamilyControls
import DeviceActivity

// Schedule device activity monitoring and limits
protocol DeviceActivityScheduling{
    //Request authorization for device activity monitoring
    func requestAuthorization() async throws -> Bool

    func scheduleShield(id: String, start: Date, end: Date) async throws
    

    //Aply a shield immediately for a duration of seconds
    func applyShieldNow(id: String, duration: TimeInterval) async throws

    //Cancel a scheduled shield by id
    func cancelScheduledShield(id: String) async throws

    ///Remove an active shield immediately by id
    func removeActiveShield(id: String) async throws

    func startMonitoring(categories: [String]) async throws

    func stopMonitoring() async throws
}
final class DeviceActivityScheduler: DeviceActivityScheduling{
    func requestAuthorization() async throws -> Bool {

        // Implementation goes here
        
        



        return false
    }

    func scheduleShield(id: String, start: Date, end: Date) async throws {
        // Implementation goes here
    }

    func applyShieldNow(id: String, duration: TimeInterval) async throws {
        // Implementation goes here
    }

    func cancelScheduledShield(id: String) async throws {
        // Implementation goes here
    }

    func removeActiveShield(id: String) async throws {
        // Implementation goes here
    }

    func startMonitoring(categories: [String]) async throws {
        // Implementation goes here
    }

    func stopMonitoring() async throws {
        // Implementation goes here
    }
}





enum DeviceActivitySchedulerError: Error{
    case authorizationDenied
    case schedulingFailed
    case removalFailed
    case monitoringFailed
}
