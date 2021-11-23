//
//  AppSession.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import Foundation

//User Userdefault keys
struct UserDefaultKey {
    static let contactInfo = "contact_info"
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
