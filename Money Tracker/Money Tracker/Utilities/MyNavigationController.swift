//
//  MyNavigationController.swift
//  Money Tracker
//
//  Created by Banghua Zhao on 10/2/20.
//

import UIKit

class MyNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    func setNavigationBar() {
        let compactAppearance = UINavigationBarAppearance()
        compactAppearance.configureWithTransparentBackground()
        compactAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        compactAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        compactAppearance.backgroundColor = .clear

        navigationBar.isTranslucent = true
        navigationBar.standardAppearance = compactAppearance
        navigationBar.compactAppearance = compactAppearance
        navigationBar.scrollEdgeAppearance = compactAppearance
    }

    func setBackground(color: UIColor) {
        navigationBar.standardAppearance.backgroundColor = color
        navigationBar.compactAppearance?.backgroundColor = color
        navigationBar.scrollEdgeAppearance?.backgroundColor = color
    }

    func setTintColor(color: UIColor) {
        navigationBar.tintColor = color
    }

    func setTitleTextColor(color: UIColor) {
        navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: color]
        navigationBar.standardAppearance.largeTitleTextAttributes = [.foregroundColor: color]
        navigationBar.compactAppearance?.titleTextAttributes = [.foregroundColor: color]
        navigationBar.compactAppearance?.largeTitleTextAttributes = [.foregroundColor: color]
        navigationBar.scrollEdgeAppearance?.titleTextAttributes = [.foregroundColor: color]
        navigationBar.scrollEdgeAppearance?.largeTitleTextAttributes = [.foregroundColor: color]
    }
}
