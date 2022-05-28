//
//  UITableView + Extension.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit

extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 20, y: 20, width: self.bounds.size.width - 40, height: self.bounds.size.height - 40))
        messageLabel.text = message
        messageLabel.textColor = .gray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name:"HelveticaNeueeTextPro-LtIt", size: 15)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
    }
    
    func setEmptyImage(_ imageName: String) {
        let imageView = UIImageView(frame: CGRect(x: 20, y: 20, width: self.bounds.size.width - 40, height: self.bounds.size.height - 40))
        imageView.image = UIImage(named: imageName, in: Bundle.messageKitAssetBundle, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        self.backgroundView = imageView
    }
    
    func resetBackgroundView() {
        backgroundView = nil
    }
}

extension UIScrollView {
    func scrollToBottom(animated: Bool = true) {
        guard contentSize.height > bounds.size.height else { return }

        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        setContentOffset(bottomOffset, animated: true)
    }
}
