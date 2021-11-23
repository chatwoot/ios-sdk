//
//  StoryBoardConstant.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit

protocol StoryboardScene: RawRepresentable {

    static var storyboardName: String {get}
}

extension StoryboardScene {

    static func storyboard() -> UIStoryboard {
        return UIStoryboard(name: self.storyboardName, bundle: nil)
    }

    func viewController() -> UIViewController {
        // swiftlint:disable:next force_cast
        return Self.storyboard().instantiateViewController(withIdentifier: self.rawValue as! String)
    }
}

extension UIStoryboard {
    struct Main {
        private enum Identifier: String, StoryboardScene {
            static let storyboardName   = "Main"
            case conversationDetailsVC  = "ConversationDetailsVC"
        }

        static func conversationDetailsVC() -> UIViewController {
            return Identifier.conversationDetailsVC.viewController()
        }
    }
}
