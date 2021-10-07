//
//  SwitchAccountViewModel.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit
import Alamofire

protocol SwitchAccountDelegate: AnyObject {
    func getAccessToken(data: SwitchAccountModel)
}

class SwitchAccountViewModel: NSObject {
    weak var delegate: SwitchAccountDelegate?    
    func callSwitchAccountApi() {
        //FIXME:- Hardcoded for Testing
        let switchParams = SwitchAccountRequest(phoneNumber: "", password: "", fraction: "", fcmToken: "" )
        
        ProgressHUD.show()
        HomeRouter().switchAccountApi(params: switchParams) { [ weak self] result in
            switch result {
            case .success(let result):
                self?.delegate?.getAccessToken(data: result)
                print(result.sessionID)
                SetUserDefaults.authToken(result.sessionID)
                ProgressHUD.dismiss()
            case .failure( _):
                ProgressHUD.dismiss()
                break
            }
        }
    }
}
