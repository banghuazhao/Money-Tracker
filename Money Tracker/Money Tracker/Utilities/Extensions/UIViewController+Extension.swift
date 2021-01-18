//
//  UIViewController+Extension.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 2021/1/17.
//

import UIKit

// MARK: - hideKeyboardWhenTappedAround

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))

        tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
