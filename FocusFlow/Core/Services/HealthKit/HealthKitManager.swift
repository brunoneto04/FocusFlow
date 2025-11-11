import Foundation
import HealthKit

/// Placeholder HealthKit manager: request authorization and simple queries
final class HealthKitManager {
    private let store = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        // TODO: define types and request authorization
        completion(false, nil)
    }
}
