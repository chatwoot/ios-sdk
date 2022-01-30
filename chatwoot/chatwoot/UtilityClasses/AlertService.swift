//
//  AlertService.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import Foundation
import UIKit

class AlertService {
    static func showAlert(style: UIAlertController.Style, title: String?, message: String?, actions: [UIAlertAction] = [UIAlertAction(title: "Ok", style: .cancel, handler: nil)], completion: (() -> Swift.Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in actions {
            alert.addAction(action)
        }
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        keyWindow?.topViewController()?.present(alert, animated: true, completion: completion)
    }
}


