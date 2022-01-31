//
//  PaddingLabel.swift
//  chatwoot
//
//  Created by shamzz on 01/02/22.
//

import UIKit

class PaddingLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        super.drawText(in: rect.inset(by: insets))
    }
}
