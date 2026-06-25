//
//  CoreDataManager.swift
//  BMI Diary
//
//  Created by Banghua Zhao on 7/4/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import CoreData

@MainActor
final class CoreDataManager {
    static let shared = CoreDataManager()

    /// CloudKit container identifier. Must match the iCloud capability configured
    /// in Signing & Capabilities (and the App ID in the developer portal).
    static let cloudKitContainerID = "iCloud.com.Banghua-Zhao.Money-Tracker"

    let persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Model")

        if let description = container.persistentStoreDescriptions.first {
            // Required for CloudKit mirroring: track history and post a
            // notification when another device pushes a change.
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

            // Mirror the local store to the user's private CloudKit database so
            // data syncs across their devices (iPhone ↔ Mac).
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: CoreDataManager.cloudKitContainerID
            )
        }

        container.loadPersistentStores { _, err in
            if let err = err {
                // Don't crash: if CloudKit is unreachable or the account is
                // signed out, the app still works against the local store.
                print("Loading of store failed: \(err)")
            }
        }

        // Keep the UI context up to date as remote changes are merged in.
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        try? container.viewContext.setQueryGenerationFrom(.current)
        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func fetchLocalTransactions() -> [Transaction] {
        let fetchRequest = NSFetchRequest<Transaction>(entityName: "Transaction")
        do {
            return try viewContext.fetch(fetchRequest)
        } catch let fetchErr {
            print("Failed to fetch User transaction:", fetchErr)
            return []
        }
    }

    func saveContext() {
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context:", error)
        }
    }

    /// Deletes every transaction. Used to clear the first-run sample data.
    func deleteAllTransactions() {
        let transactions = fetchLocalTransactions()
        guard !transactions.isEmpty else { return }
        for transaction in transactions {
            viewContext.delete(transaction)
        }
        saveContext()
    }
}
