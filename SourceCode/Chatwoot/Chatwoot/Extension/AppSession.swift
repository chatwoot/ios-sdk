//
//  AppSession.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import Foundation
import UIKit

//User Userdefault keys
struct UserDefaultKey {
    static let contactInfo = "contact_info"
    static let primaryColor = "primary_color"
}

//Getter
struct GetUserDefaults {
    static var contactInfo: CreateContactModel! {
        var contactInfoStored: CreateContactModel?  = nil
        if let data = UserDefaults.standard.data(forKey: UserDefaultKey.contactInfo) {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode contactInfo
                contactInfoStored = try decoder.decode(CreateContactModel.self, from: data)

            } catch {
                print("Unable to Decode contactInfo (\(error))")
            }
        }
        return contactInfoStored
    }
    
    static func getPrimaryColor() -> UIColor {
        UserDefaults.standard.data(forKey: UserDefaultKey.primaryColor)?.color ?? UIColor(red: 71/255, green: 145/255, blue: 247/255, alpha: 1)
    }
}

//Setter
struct SetUserDefaults {
    static func contactInfo(_ contactModel: CreateContactModel) {
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode contactInfo
            let data = try encoder.encode(contactModel)

            // Write/Set Data
            UserDefaults.standard.set(data, forKey: UserDefaultKey.contactInfo)
            UserDefaults.standard.synchronize()

        } catch {
            print("Unable to Encode contactInfo (\(error))")
        }
    }
    
    static func setPrimaryColor(_ color: UIColor?) {
        guard let data = color?.data else {
            UserDefaults.standard.removeObject(forKey: UserDefaultKey.primaryColor)
            UserDefaults.standard.synchronize()
            return
        }
        UserDefaults.standard.set(data, forKey: UserDefaultKey.primaryColor)
        UserDefaults.standard.synchronize()
    }
}

extension UserDefaults {
    
    func setStringValueFor (key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func getStringValueFor (key: String) -> String {
        let value = UserDefaults.standard.string(forKey: key)
        return (value == nil) ? "" : value!
    }
    
    func setCustomObjectFor (key: String, value: Data) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
}

extension Numeric {
    var data: Data {
        var bytes = self
        return Data(bytes: &bytes, count: MemoryLayout<Self>.size)
    }
}

extension Data {
    func object<T>() -> T { withUnsafeBytes{$0.load(as: T.self)} }
    var color: UIColor { .init(data: self) }
}

extension UIColor {
    convenience init(data: Data) {
        let size = MemoryLayout<CGFloat>.size
        self.init(red:   data.subdata(in: size*0..<size*1).object(),
                  green: data.subdata(in: size*1..<size*2).object(),
                  blue:  data.subdata(in: size*2..<size*3).object(),
                  alpha: data.subdata(in: size*3..<size*4).object())
    }
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var (red, green, blue, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        return getRed(&red, green: &green, blue: &blue, alpha: &alpha) ?
        (red, green, blue, alpha) : nil
    }
    var data: Data? {
        guard let rgba = rgba else { return nil }
        return rgba.red.data + rgba.green.data + rgba.blue.data + rgba.alpha.data
    }
}
