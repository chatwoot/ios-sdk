//
//  CreateContactViewModel.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit
import Alamofire

protocol AllConversationsDelegate: AnyObject {
    func contactCreated(data: CreateContactModel)
    func listAllConversations(data: [AllConversationsModel])
    func networkOfflineAlert()
}

class AllConversationsViewModel: NSObject {
    weak var delegate: AllConversationsDelegate?
    func createContactApi() {
        if (NetworkReachabilityManager()!.isReachable) {
            //FIXME:- Hardcoded for Testing
            let createContactParams = CreateContactRequest(identifier: nil, identifier_hash: nil, email: "testing@gmail.com", name: "Shamsu", avatar_url: "", custom_attributes: nil)
            ProgressHUD.show()
            HomeRouter().createContactApi(params: createContactParams) { [ weak self] result in
                switch result {
                case .success(let result):
                    SetUserDefaults.contactInfo(result)
                    self?.delegate?.contactCreated(data: result)
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
    
    func listAllConversationsApi() {
        if (NetworkReachabilityManager()!.isReachable) {
            ProgressHUD.show()
            HomeRouter().listAllConversationsApi() { [ weak self] result in
                switch result {
                case .success(let result):
                    self?.delegate?.listAllConversations(data: result)
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
