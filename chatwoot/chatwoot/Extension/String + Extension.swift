//
//  String + Extension.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit

extension String {
    func prepareContactIdentifier() -> String {
        var contactIdentifier = ""
        if let contactInfo = GetUserDefaults.contactInfo {
            if let sourceID = contactInfo.sourceID {
                contactIdentifier = self.replacingOccurrences(of: "{contact_identifier}", with:sourceID)
            }
        }
        return contactIdentifier
    }
}
