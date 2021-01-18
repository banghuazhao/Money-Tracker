//
//  Double+Extension.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 2021/1/17.
//

import Foundation

extension Double {
    /// 小数点后如果只是0，显示整数，如果不是，显示原来的值

    var cleanZero: String {
        return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.2f", self)
    }
}
