//
//  BackupManager.swift
//  Money Tracker
//

import CloudKit
import CoreData
import Foundation

// MARK: - Codable models

struct TransactionBackup: Codable {
    var amount: Double
    var category: String
    var date: Date
    var title: String?
}

struct CategoryBackup: Codable {
    var name: String
    var iconName: String
    var isIncome: Bool
}

// MARK: - BackupEntry

struct BackupEntry {
    let record: CKRecord
    let date: Date
    let transactionCount: Int
    let categoryCount: Int
}

// MARK: - BackupManager

final class BackupManager {
    static let shared = BackupManager()
    private init() {}

    private let container = CKContainer(identifier: "iCloud.com.apps-bay.Money-Tracker")
    private var db: CKDatabase { container.privateCloudDatabase }
    private let recordType = "MoneyTrackerBackup"

    // MARK: - Save

    func saveBackup() async throws {
        let transactions = await MainActor.run { CoreDataManager.shared.fetchLocalTransactions() }
        let categories = await MainActor.run { UserCategoryManager.shared.fetchAll() }

        let txBackups = transactions.map { t in
            TransactionBackup(
                amount: t.amount,
                category: t.category ?? "",
                date: t.date ?? Date(),
                title: t.title
            )
        }
        let catBackups = categories.map { c in
            CategoryBackup(
                name: c.name ?? "",
                iconName: c.iconName ?? "",
                isIncome: c.isIncome
            )
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let txData = try encoder.encode(txBackups)
        let catData = try encoder.encode(catBackups)

        let record = CKRecord(recordType: recordType)
        record["date"] = Date() as CKRecordValue
        record["transactionsJSON"] = String(data: txData, encoding: .utf8)! as CKRecordValue
        record["categoriesJSON"] = String(data: catData, encoding: .utf8)! as CKRecordValue
        record["transactionCount"] = txBackups.count as CKRecordValue
        record["categoryCount"] = catBackups.count as CKRecordValue

        try await db.save(record)
    }

    // MARK: - Fetch

    func fetchBackups() async throws -> [BackupEntry] {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        var allRecords: [CKRecord] = []
        var cursor: CKQueryOperation.Cursor? = nil

        repeat {
            let result: (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?)
            if let cursor {
                result = try await db.records(continuingMatchFrom: cursor)
            } else {
                result = try await db.records(matching: query)
            }
            for (_, recordResult) in result.matchResults {
                if let record = try? recordResult.get() {
                    allRecords.append(record)
                }
            }
            cursor = result.queryCursor
        } while cursor != nil

        return allRecords.compactMap { record in
            guard let date = record["date"] as? Date else { return nil }
            let txCount = record["transactionCount"] as? Int ?? 0
            let catCount = record["categoryCount"] as? Int ?? 0
            return BackupEntry(record: record, date: date, transactionCount: txCount, categoryCount: catCount)
        }
    }

    // MARK: - Delete

    func deleteBackup(record: CKRecord) async throws {
        try await db.deleteRecord(withID: record.recordID)
    }

    func deleteAllBackups() async throws {
        let entries = try await fetchBackups()
        for entry in entries {
            try await deleteBackup(record: entry.record)
        }
    }

    // MARK: - Restore

    @MainActor
    func restoreFromBackup(entry: BackupEntry) throws {
        guard
            let txJSON = entry.record["transactionsJSON"] as? String,
            let catJSON = entry.record["categoriesJSON"] as? String,
            let txData = txJSON.data(using: .utf8),
            let catData = catJSON.data(using: .utf8)
        else {
            throw NSError(domain: "BackupManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid backup data"])
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let txBackups = try decoder.decode([TransactionBackup].self, from: txData)
        let catBackups = try decoder.decode([CategoryBackup].self, from: catData)

        let context = CoreDataManager.shared.viewContext

        // Clear existing data
        let existingTransactions = CoreDataManager.shared.fetchLocalTransactions()
        existingTransactions.forEach { context.delete($0) }
        let existingCategories = UserCategoryManager.shared.fetchAll()
        existingCategories.forEach { context.delete($0) }

        // Import transactions
        for tx in txBackups {
            let t = Transaction(context: context)
            t.amount = tx.amount
            t.category = tx.category
            t.date = tx.date
            t.title = tx.title
        }

        // Import categories
        for cat in catBackups {
            let c = UserCategory(context: context)
            c.uuid = UUID()
            c.name = cat.name
            c.iconName = cat.iconName
            c.isIncome = cat.isIncome
        }

        try context.save()
    }
}
