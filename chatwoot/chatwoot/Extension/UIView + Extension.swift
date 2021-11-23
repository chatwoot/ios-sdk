//
//  UIView + Extension.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}


extension UIColor {
    static func random() -> UIColor {
        let colors = [#colorLiteral(red: 0.4402326345, green: 0.8666530252, blue: 0.999440968, alpha: 1), #colorLiteral(red: 0.9965530038, green: 0.6181388497, blue: 0.6182960272, alpha: 1), #colorLiteral(red: 0.5531654954, green: 0.5724850297, blue: 1, alpha: 1), #colorLiteral(red: 0.08587420732, green: 0.7819225192, blue: 0.6138077378, alpha: 1), #colorLiteral(red: 0.73091501, green: 0.3417928517, blue: 0.6247475743, alpha: 1), #colorLiteral(red: 0.9281603694, green: 0.6919323206, blue: 0.3306260705, alpha: 1), #colorLiteral(red: 0.5154118538, green: 0.6103749871, blue: 0, alpha: 1), #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)]
        let randomNumber = arc4random_uniform(UInt32(colors.count))
        return colors[Int(randomNumber)]
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}


extension UIView {
    func setGradientBackground() {
        let layer0 = CAGradientLayer()
        layer0.colors = [
          UIColor(red: 0.783, green: 0.872, blue: 0.954, alpha: 1).cgColor,
            UIColor(red: 0.769, green: 0.769, blue: 0.769, alpha: 0.1).cgColor
        ]
        layer0.locations = [0, 1]
        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))
        layer0.frame = self.bounds
        layer0.position = self.center
        self.layer.insertSublayer(layer0, at: 0)
    }
    
    func topRoundCorners(radius: CGFloat,_ vframe: CGRect? = nil) {
        let mask = CAShapeLayer()
        var path: UIBezierPath!
        if layer.mask == nil {
            if let viewFrame = vframe {
                path = UIBezierPath(roundedRect: viewFrame, byRoundingCorners: [.topLeft, .topRight], cornerRadii: .init(width: radius, height: radius))
            } else {
                path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: .init(width: radius, height: radius))
            }
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
    
    func bottomRoundCorners(radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: .init(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension CGFloat {
    func getminimum(value2:CGFloat)->CGFloat {
        if self < value2 {
            return self
            
        } else {
            return value2
            
        }
    }
}
