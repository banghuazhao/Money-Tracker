//
//  FeedbackItem.swift
//  Financial Statements Go
//
//  Created by Banghua Zhao on 1/1/21.
//  Copyright © 2021 Banghua Zhao. All rights reserved.
//

import UIKit

struct FeedbackItem {
    var title: String
    var detail: String
    let icon: UIImage?
    init(title: String, detail: String, icon: UIImage?) {
        self.title = title
        self.detail = detail
        self.icon = icon
    }
}
