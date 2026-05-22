//
//  Persistence.swift
//  HLFIYA
//
//  Created by Ryan Token on 1/17/22.
//

import CoreData
import os

struct PersistenceController {
    static let shared = PersistenceController()

    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        for _ in 0..<10 {
            let rightSwipe = RightSwipe(context: context)
            rightSwipe.name = "Chick Fil A"
            rightSwipe.uuid = UUID()
        }

        do {
            try context.save()
        } catch {
            Self.logger.error("Failed to seed preview store: \(error.localizedDescription, privacy: .public)")
        }
        return controller
    }()

    let container: NSPersistentCloudKitContainer

    private static let logger = Logger(subsystem: "com.ryantoken.HLFIYA", category: "Persistence")

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "HLFIYA")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }

        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }

        // Persistent history tracking and remote-change notifications are required
        // for NSPersistentCloudKitContainer so the view context picks up changes
        // pulled in from iCloud (and from any background contexts).
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                Self.logger.error("Failed to load persistent store: \(error.localizedDescription, privacy: .public)")
                assertionFailure("Failed to load persistent store: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.name = "ViewContext"
        container.viewContext.transactionAuthor = "app"
    }
}
