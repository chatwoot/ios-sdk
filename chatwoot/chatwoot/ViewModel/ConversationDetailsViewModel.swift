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
    
    func listAllMessagesApi() {
        if (NetworkReachabilityManager()!.isReachable) {
            ProgressHUD.show()
            HomeRouter().listAllMessagesApi() { [ weak self] result in
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
    
    func sendTextMessageApi(textMessage: String) {
        if (NetworkReachabilityManager()!.isReachable) {
            let sendTextMessageParam = SendTextMessageModelRequest(content: textMessage)
            ProgressHUD.show()
            HomeRouter().sendTextMessageApi(params: sendTextMessageParam) { [ weak self] result in
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
