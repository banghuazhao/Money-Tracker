//
//  TransactionCategory.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/6/20.
//

import Foundation

class TransactionCategory {
    let category: String
    var amount: Double
    init(category: String, amount: Double = 0.0) {
        self.category = category
        self.amount = amount
    }
}
