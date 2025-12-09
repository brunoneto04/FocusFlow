import Foundation
import HealthKit
import Combine

@MainActor
final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    enum AuthorizationError: Error {
        case stepTypeUnavailable
    }

    private let healthStore = HKHealthStore()
    private let calendar: Calendar

    @Published private(set) var todaysSteps: Int = 0
    @Published var isAuthorized: Bool = false

    private init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    var isHealthAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    private var readTypes: Set<HKObjectType> {
        guard let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return []
        }
        return [stepsType]
    }

    func requestAuthorization() async -> Bool {
        guard isHealthAvailable, !readTypes.isEmpty else {
            isAuthorized = false
            return false
        }

        do {
            try await healthStore.requestAuthorization(toShare: nil, read: readTypes)
            isAuthorized = true
            return true
        } catch {
            isAuthorized = false
            return false
        }
    }

    func fetchTodaySteps() async throws -> Int {
        guard isAuthorized else {
            todaysSteps = 0
            return 0
        }

        guard let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            throw AuthorizationError.stepTypeUnavailable
        }

        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { [weak self] continuation in
            let query = HKStatisticsQuery(
                quantityType: stepsType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let value = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                let steps = Int(value)

                DispatchQueue.main.async {
                    self?.todaysSteps = steps
                }

                continuation.resume(returning: steps)
            }

            self?.healthStore.execute(query)
        }
    }

    func fetchTodaySteps(completion: ((Int) -> Void)? = nil) {
        Task {
            let steps = (try? await fetchTodaySteps()) ?? 0
            await MainActor.run {
                completion?(steps)
            }
        }
    }
}
