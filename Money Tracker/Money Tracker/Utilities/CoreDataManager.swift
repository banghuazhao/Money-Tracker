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

    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, err in
            if let err = err {
                fatalError("Loading of store failed: \(err)")
            }
        }
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
