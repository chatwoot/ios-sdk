//
//  ConversationDetailsViewModel.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit
import Alamofire

protocol ConversationDetailsDelegate: AnyObject {
    func listAllMessages(data: [MessageModel])
    func networkOfflineAlert()
    func textMessageDelivered(data: MessageModel)
}

class ConversationDetailsViewModel: NSObject {
    weak var delegate: ConversationDetailsDelegate?
    
    func listAllMessagesApi(conversationID: String) {
        if (NetworkReachabilityManager()!.isReachable) {
            ProgressHUD.show()
            HomeRouter().listAllMessagesApi(conversationID: conversationID) { [ weak self] result in
                switch result {
                case .success(let result):
                    self?.delegate?.listAllMessages(data: result)
                    ProgressHUD.dismiss()
                case .failure( _):
                    ProgressHUD.dismiss()
                    break
                }
            }
        }
        else {
            self.delegate?.networkOfflineAlert()
        }
    }
    
    func sendTextMessageApi(conversationID: String, textMessage: String) {
        if (NetworkReachabilityManager()!.isReachable) {
            let sendTextMessageParam = SendTextMessageModelRequest(content: textMessage)
            ProgressHUD.show()
            HomeRouter().sendTextMessageApi(conversationID: conversationID, params: sendTextMessageParam) { [ weak self] result in
                switch result {
                case .success(let result):
                    self?.delegate?.textMessageDelivered(data: result)
                    ProgressHUD.dismiss()
                case .failure( _):
                    ProgressHUD.dismiss()
                    break
                }
            }
        }
        else {
            self.delegate?.networkOfflineAlert()
        }
    }
}
