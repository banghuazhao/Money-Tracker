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
        navigationBar.prefersLargeTitles = true
        setNavigationBar()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    func setNavigationBar() {
        if #available(iOS 26.0, *) {
            // Liquid Glass: use default background so the system applies the glass material
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            navigationBar.standardAppearance = appearance
            navigationBar.compactAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            appearance.backgroundColor = .clear
            navigationBar.isTranslucent = true
            navigationBar.standardAppearance = appearance
            navigationBar.compactAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        }
    }

    func setBackground(color: UIColor) {
        // No-op on iOS 26+: overriding background would remove the Liquid Glass material
        if #available(iOS 26.0, *) { return }
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
