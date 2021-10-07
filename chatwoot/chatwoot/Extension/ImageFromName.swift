//
//  ImageFromName.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit

public class ImageFromName: NSObject {
    
    // MARK: - Variables
    public var text: String = ""
    
    private var imageRadius: Double = 0
    private var imageSize: Double = 0
    public var radius: Double {
        get {
            return imageRadius
        }
        set {
            imageRadius = newValue
            imageSize = imageRadius * 2
        }
    }
    
    public var font: UIFont?
    public var textColor: UIColor?
    public var backgroundColor: UIColor?
    // MARK: - Initailization
    /**
     Initialize an IPImage object. The default value of `radius` is 25. `text` is empty.
    */
    public convenience override init() {
        self.init(text: "", radius: 25)
    }
        
    /**
     Initialize an IPImage object.
     
     - Parameters:
         - text: Source of the initials
         - radius: Circular image radius
         - textColor: Color of the text at the center
         - randomBackgroundColor: Randomized fill color
     */
    public init(text: String, radius: Double = 0,fontSize: CGFloat = 14,_ textColor: UIColor = .black,_ backgroundColor: UIColor? = nil) {
        super.init()
        
        self.text = text.components(separatedBy: " ").first ?? ""
        self.radius = radius
        self.textColor = textColor
        if let color = backgroundColor {
            self.backgroundColor = color
        } else {
            self.backgroundColor = self.randomColor()
        }
            let customFont = UIFont(name: "Biennale-Regular", size: fontSize)
            self.font = customFont
    }
        
    // MARK: - Private
    private func randomColor() -> UIColor {
        let arrayColors = [#colorLiteral(red: 0.4901467562, green: 0.4902250767, blue: 0.4901347756, alpha: 1), #colorLiteral(red: 1, green: 0.5960784314, blue: 0, alpha: 1), #colorLiteral(red: 0.2470588235, green: 0.3176470588, blue: 0.7098039216, alpha: 1), #colorLiteral(red: 0.9568627451, green: 0.262745098, blue: 0.2117647059, alpha: 1), #colorLiteral(red: 0.6117647059, green: 0.1529411765, blue: 0.6901960784, alpha: 1), #colorLiteral(red: 0.4039215686, green: 0.2274509804, blue: 0.7176470588, alpha: 1), #colorLiteral(red: 0.1294117647, green: 0.5882352941, blue: 0.9529411765, alpha: 1), #colorLiteral(red: 1, green: 0.9215686275, blue: 0.231372549, alpha: 1), #colorLiteral(red: 0.2980392157, green: 0.6862745098, blue: 0.3137254902, alpha: 1), #colorLiteral(red: 0, green: 0.5882352941, blue: 0.5333333333, alpha: 1)]
        _ = Int(arc4random_uniform(UInt32(arrayColors.count)))

        return arrayColors[0]
    }
    
    private func setupView() -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        view.backgroundColor = backgroundColor
        view.addSubview(setupLabel())
        rounded(view: view)
        
        return view
    }
    
    private func setupViewRectangle() -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        view.backgroundColor = backgroundColor
        view.addSubview(setupLabel())
        return view
    }

    
    private func setupLabel() -> UILabel {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        label.text = initials().capitalized
        label.font = font
        label.textColor = textColor
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.allowsDefaultTighteningForTruncation = true
        return label
        
    }
    
    private func rounded(view: UIView) {
        
        let width = view.frame.width
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(ovalIn: CGRect(x: view.bounds.midX - width / 2, y: view.bounds.midY - width / 2, width: width, height: width)).cgPath
        view.layer.mask = mask
    }
    
    // MARK: - Text Generation
    
    /**
     Generates the initials from the value of `text`. For example:
     
         text = "Harry"
     
     the result will be: **H**. If:
     
         text = "Harry Potter"
     
     the result will be: **HP**. And, if:
     
         text = "Harry Potter Jr."
     
     the result will be **HJ**.
     
     
     - Returns: String which is one or two charaters long depending on the number of words in `text`.
    */
    public func initials() -> String {
        
        let names = text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
            
        if names.count > 1 {
            let firstName = names[0]
            let lastName = names[names.count - 1]
            
            let firstNameInitial = firstName != "" ? String(firstName.prefix(1)) : ""
            let lastNameInitial = lastName != "" ? String(lastName.prefix(1)) : ""
            
            return (firstNameInitial + lastNameInitial)
            
        } else {
            if text == "" {
                return ""
            }
            return String(text.prefix(1))
        }
    }
    
    // MARK: - Image Generation
    
    /**
     Call to generate the resulting image.
     
     - Returns: Circular image
    */
    public func generateImage() -> UIImage? {
        
        let view = setupView()
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { rendererContext in
            view.layer.render(in: rendererContext.cgContext)
        }
    }
    
    /**
     Call to generate the resulting image.
     
     - Returns: Rectangle image
    */
    
    public func generateImageRectangle() -> UIImage? {
        
        let view = setupViewRectangle()
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { rendererContext in
            view.layer.render(in: rendererContext.cgContext)
        }
    }
}
