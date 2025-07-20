import CoreData

/// Singleton wrapper around Core Data stack
struct PersistenceController {
    static let shared = PersistenceController()

    /// For SwiftUI previews / tests — no disk writes
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        // Add sample data here if desired
        let context = controller.container.viewContext
        // Example: create stub Audit entity here later

        try? context.save()
        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "LagAuditApp")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
