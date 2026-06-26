//
//  UserCategory+CoreDataProperties.swift
//  Money Tracker
//

import CoreData
import Foundation

extension UserCategory {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserCategory> {
        return NSFetchRequest<UserCategory>(entityName: "UserCategory")
    }

    @NSManaged public var iconName: String?
    @NSManaged public var isIncome: Bool
    @NSManaged public var name: String?
    @NSManaged public var uuid: UUID?
}

extension UserCategory: Identifiable {}
