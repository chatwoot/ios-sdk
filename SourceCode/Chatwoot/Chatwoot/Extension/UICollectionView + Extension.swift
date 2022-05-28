//
//  UICollectionView + Extension.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit

extension UICollectionView {
    func setEmptyMessage(_ message: String, size: CGFloat = 15) {
        let messageLabel = UILabel(frame: CGRect(x: 20, y: 20, width: self.bounds.size.width - 40, height: self.bounds.size.height - 40))
        messageLabel.text = message
        messageLabel.textColor = .gray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "HelveticaNeueeTextPro-MdIt", size: size)
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
