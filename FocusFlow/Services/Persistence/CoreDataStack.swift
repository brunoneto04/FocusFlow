import Foundation
import CoreData

// Minimal Core Data stack placeholder
final class CoreDataStack {
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FocusFlowModel")
        container.loadPersistentStores { _, _ in }
        return container
    }()
}
