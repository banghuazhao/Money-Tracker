//
//  Other.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/4/20.
//

import Foundation

func convertDoubleToCurrency(amount: Double) -> String {
    let numberFormatter = NumberFormatter()
    if let currencyCode = UserDefaults.standard.value(forKey: UserDefaultsKeys.CURRENCY) as? String {
        if let identifier = Locale.availableIdentifiers.first(where: { Locale(identifier: $0).currencyCode == currencyCode }) {
            numberFormatter.locale = Locale(identifier: identifier)
        }
    } else {
        numberFormatter.locale = Locale.current
    }

    numberFormatter.numberStyle = .currency
    numberFormatter.negativePrefix = numberFormatter.minusSign + numberFormatter.currencySymbol
    numberFormatter.minimumFractionDigits = 0
    numberFormatter.maximumFractionDigits = 2
    return numberFormatter.string(from: NSNumber(value: amount))!
}
