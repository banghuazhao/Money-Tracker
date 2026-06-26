//
//  UserCategoryManager.swift
//  Money Tracker
//

import CoreData
import Foundation

@MainActor
final class UserCategoryManager {
    static let shared = UserCategoryManager()
    private init() {}

    func fetchAll() -> [UserCategory] {
        let request = UserCategory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            return try CoreDataManager.shared.viewContext.fetch(request)
        } catch {
            print("Failed to fetch UserCategory:", error)
            return []
        }
    }

    func expenseCategories() -> [UserCategory] {
        fetchAll().filter { !$0.isIncome }
    }

    func incomeCategories() -> [UserCategory] {
        fetchAll().filter { $0.isIncome }
    }

    func category(forName name: String) -> UserCategory? {
        fetchAll().first { $0.name == name }
    }

    @discardableResult
    func create(name: String, iconName: String, isIncome: Bool) -> UserCategory {
        let context = CoreDataManager.shared.viewContext
        let cat = UserCategory(context: context)
        cat.uuid = UUID()
        cat.name = name
        cat.iconName = iconName
        cat.isIncome = isIncome
        CoreDataManager.shared.saveContext()
        return cat
    }

    func delete(_ category: UserCategory) {
        CoreDataManager.shared.viewContext.delete(category)
        CoreDataManager.shared.saveContext()
    }
}
