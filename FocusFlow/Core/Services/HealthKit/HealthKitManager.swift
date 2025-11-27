import Foundation
import HealthKit
import Combine

final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

    @Published private(set) var todaysSteps: Int = 0

    private init() {}
    
    var isHealthAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    
    
    
    
    private var readTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()
        if let steps = HKObjectType.quantityType(forIdentifier: .stepCount) {
            types.insert(steps)
        }
        return types
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("HealthKit auth error: \(error.localizedDescription)")
                }
                completion(success)
            }
        }
    }

    func fetchTodaySteps(completion: ((Int) -> Void)? = nil) {
        guard let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion?(0)
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepsType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, _ in
            let value = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            let steps = Int(value)

            DispatchQueue.main.async {
                self?.todaysSteps = steps
                completion?(steps)
            }
        }

        healthStore.execute(query)
    }
}
