//
//  UIImageView + Extension.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    //Downloading and Cache image
    func setImageFromUrl(url: String,_ name: String = "",_ fontSize: Int = 10,bgColor: UIColor = .white) {
        if let url = URL(string:url) {
            self.kf.setImage(with: url) { result in
                switch result {
                case .success(let value):
                    self.image = value.image
                case .failure(let error):
                    print("Error: \(error)")
                    guard name != "" else {
                        return
                    }
                    let image = ImageFromName(text: name.capitalized ,radius: 15, fontSize: CGFloat(fontSize),bgColor)
                    self.image = image.generateImage()
                }
            }
        }
    }
    
    func rotateDownloadedImageFromUrl(url: String) {
        if let url = URL(string:url) {
            self.kf.setImage(with: url) { result in
                switch result {
                case .success(let value):
                    //                    print("Image: \(value.image). Got from: \(value.cacheType)")
                    self.image = self.rotateImage(image: value.image)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
    
    private func rotateImage(image:UIImage) -> UIImage
    {
        var rotatedImage = UIImage()
        switch image.imageOrientation
        {
        case .right:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .down)
            
        case .down:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .left)
            
        case .left:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .up)
            
        default:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .right)
        }
        
        return rotatedImage
    }
}

extension UIImage {
    //Downloading and Cache image
    func downloadImage(from urlString : String)-> UIImage{
        guard let url = URL.init(string: urlString) else {
            return UIImage.init()
        }
        let resource = ImageResource(downloadURL: url)
        var image = UIImage()
        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
            switch result {
            case .success(let value):
                print("Image: \(value.image). Got from: \(value.cacheType)")
                image = value.image
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        return image.withRenderingMode(.alwaysTemplate)
    }
}
