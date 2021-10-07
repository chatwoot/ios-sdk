//
//  ViewController.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit

class ViewController: UIViewController {

    private var switchAccountViewModel = SwitchAccountViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func switchAccountAction(_ sender: Any) {
        switchAccountViewModel.delegate = self
        switchAccountViewModel.callSwitchAccountApi()
    }
}

extension ViewController: SwitchAccountDelegate {
    func getAccessToken(data: SwitchAccountModel) {
        print(data,getAccessToken)
    }
}


