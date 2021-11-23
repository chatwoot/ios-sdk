//
//  UIViewController + Extension.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit

extension UIViewController {
    
    @discardableResult
    func showAlert(
        title: String?,
        message: String?,
        buttonTitles: [String]? = nil,
        highlightedButtonIndex: Int? = nil,
        completion: ((Int) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var allButtons = buttonTitles ?? [String]()
        if allButtons.count == 0 {
            allButtons.append("OK")
        }
        
        for index in 0..<allButtons.count {
            let buttonTitle = allButtons[index]
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: { _ in
                completion?(index)
            })
            alertController.addAction(action)
            // Check which button to highlight
            if let highlightedButtonIndex = highlightedButtonIndex, index == highlightedButtonIndex {
                alertController.preferredAction = action
            }
        }
        present(alertController, animated: true, completion: nil)
        return alertController
    }

    func showToast(message : String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.red
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.init(name: "HelveticaNeueeTextPro-LtIt", size: 15)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        
        let maxSizeTitle : CGSize = CGSize(width: self.view.bounds.size.width-16, height: self.view.bounds.size.height)
        var expectedSizeTitle : CGSize = toastLabel.sizeThatFits(maxSizeTitle)
        expectedSizeTitle = CGSize(width:maxSizeTitle.width.getminimum(value2:expectedSizeTitle.width), height: maxSizeTitle.height.getminimum(value2:expectedSizeTitle.height))
        toastLabel.frame = CGRect(x:((self.view.bounds.size.width)/2) - ((expectedSizeTitle.width+16)/2) , y: (self.view.bounds.size.height) - 100, width: expectedSizeTitle.width+16, height: expectedSizeTitle.height+16)
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.5
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func showInternetOfflineToast() {
        self.showToast(message: "Please check your internet connectivity")
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func navigateBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
