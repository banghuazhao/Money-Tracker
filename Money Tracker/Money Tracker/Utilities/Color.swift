//
//  Color.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 7/2/20.
//

import UIKit

extension UIColor {
    static let incomeGreen = UIColor.systemGreen
    static let expenseRed  = UIColor.systemRed
    static let themeColor  = UIColor.systemBlue

    static func categoryColor(for category: String) -> UIColor {
        switch category {
        case "Grocery":              return .systemGreen
        case "Transportation":       return .systemBlue
        case "Entertainment":        return .systemPurple
        case "Restaurant":           return .systemOrange
        case "House Rent":           return .systemBrown
        case "Insurance":            return .systemIndigo
        case "Travel":               return .systemTeal
        case "Education":            return .systemCyan
        case "Consumer Electronics": return .systemGray
        case "Gift":                 return .systemPink
        case "Medicine":             return .systemRed
        case "Salary":               return .systemGreen
        case "Investment Income":    return .systemMint
        case "Other Income":         return .systemGreen
        default:                     return .systemGray
        }
    }
}
