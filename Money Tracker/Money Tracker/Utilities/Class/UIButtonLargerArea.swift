//
//  UIButtonLargeArea.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/3/20.
//

import UIKit

class UIButtonLargerArea: UIButton {
    override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        let margin: CGFloat = 10
        let area = self.bounds.insetBy(dx: -margin, dy: -margin)
        return area.contains(point)
    }
}
