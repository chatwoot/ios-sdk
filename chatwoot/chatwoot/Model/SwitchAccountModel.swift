//
//  SwitchAccountModel.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import Foundation

// MARK: - SwitchAccountRequest
struct SwitchAccountRequest: Encodable {
    let phoneNumber, password, fraction, fcmToken: String
}

// MARK: - SwitchAccountModel
struct SwitchAccountModel: Codable {
    let email, phoneNumber, sessionID: String
    
    enum CodingKeys: String, CodingKey {
        case email, phoneNumber
        case sessionID = "sessionId"
    }
}
