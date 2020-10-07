//
//  CoreDataManager.swift
//  BMI Diary
//
//  Created by Banghua Zhao on 7/4/20.
//  Copyright © 2020 Banghua Zhao. All rights reserved.
//

import CoreData

struct CoreDataManager {
    static let shared = CoreDataManager() // will live forever as long as your application is still alive, it's properties will too

    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, err in
            if let err = err {
                fatalError("Loading of store failed: \(err)")
            }
        }
        return container
    }()

    func fetchLocalTransactions() -> [Transaction] {
        let context = persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<Transaction>(entityName: "Transaction")
        do {
            let userWeights = try context.fetch(fetchRequest)
            return userWeights
        } catch let fetchErr {
            print("Failed to fetch User transaction:", fetchErr)
            return []
        }
    }
}
