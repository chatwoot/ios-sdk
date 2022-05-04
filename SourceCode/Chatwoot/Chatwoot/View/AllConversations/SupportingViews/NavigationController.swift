//
//  NavigationController.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit

final class NavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return viewControllers.last?.preferredStatusBarStyle ?? .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = false
        navigationBar.tintColor = .white
        navigationBar.barTintColor = .primaryColor
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        view.backgroundColor = .primaryColor
        
        if #available(iOS 15.0, *){
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = .primaryColor // The background color.
            
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
            
        } else { // Background color support for older versions
            navigationBar.barTintColor = .primaryColor
        }
    }
    
    func setAppearanceStyle(to style: UIStatusBarStyle) {
        if style == .default {
            navigationBar.shadowImage = UIImage()
            navigationBar.barTintColor = .primaryColor
            navigationBar.tintColor = .white
            navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        } else if style == .lightContent {
            navigationBar.shadowImage = nil
            navigationBar.barTintColor = .white
            navigationBar.tintColor = UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)
            navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
            navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        }
    }

}
