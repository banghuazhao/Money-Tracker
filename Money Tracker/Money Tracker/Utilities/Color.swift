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
        case "Clothing":             return .systemPink
        case "Beauty":               return .systemPurple
        case "Membership":           return .systemIndigo
        case "Fitness":              return .systemGreen
        case "Pets":                 return .systemBrown
        case "Utilities":            return .systemYellow
        case "Childcare":            return .systemTeal
        case "Salary":               return .systemGreen
        case "Investment Income":    return .systemMint
        case "Rental Income":        return .systemOrange
        case "Freelance":            return .systemPurple
        case "Bonus":                return .systemYellow
        case "Interest Income":      return .systemCyan
        case "Savings":              return .systemMint
        case "Side Hustle Income":   return .systemTeal
        case "Other Income":         return .systemGreen
        default:                     return .systemGray
        }
    }
}

extension UIImage {
    /// SF Symbol used for categories that don't ship a bundled image asset.
    private static func categorySymbolName(for category: String) -> String {
        switch category {
        case "Clothing":           return "tshirt"
        case "Beauty":             return "sparkles"
        case "Membership":         return "wallet.pass.fill"
        case "Fitness":            return "figure.run"
        case "Pets":               return "pawprint.fill"
        case "Utilities":          return "bolt.fill"
        case "Childcare":          return "figure.and.child.holdinghands"
        case "Rental Income":      return "house.fill"
        case "Freelance":          return "laptopcomputer"
        case "Bonus":              return "star.fill"
        case "Interest Income":    return "percent"
        case "Savings":            return "banknote.fill"
        case "Side Hustle Income": return "briefcase.fill"
        default:                   return "tag.fill"
        }
    }

    /// Icon for a category: the bundled image asset if present, otherwise a
    /// tinted SF Symbol. Lets new categories be added without new artwork.
    static func categoryIcon(for category: String) -> UIImage? {
        if let asset = UIImage(named: category) {
            return asset
        }
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        let symbol = UIImage(systemName: categorySymbolName(for: category), withConfiguration: config)
            ?? UIImage(systemName: "tag.fill", withConfiguration: config)
        return symbol?.withTintColor(UIColor.categoryColor(for: category), renderingMode: .alwaysOriginal)
    }
}
