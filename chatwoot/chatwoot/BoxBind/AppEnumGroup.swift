//
//  AppEnumGroup.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit

enum Level: Int, Codable {
    case High = 1
    case Medium = 2
    case Low = 3
    
    var value: String {
        switch self {
        case .High:
            return "High"
        case .Medium:
            return "Medium"
        case .Low:
            return "Low"
        }
    }
}
