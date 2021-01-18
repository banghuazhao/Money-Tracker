//
//  UserTransaction.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/2/20.
//

import Foundation

class UserTransaction {
    let date: Date
    let amount: Double
    let category: String
    let title: String
    init(date: Date, amount: Double, category: String, title: String = "") {
        self.date = date
        self.amount = amount
        self.category = category
        self.title = title
    }
}
