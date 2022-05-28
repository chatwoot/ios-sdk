//
//  ViewController.swift
//  DemoApplication
//
//  Created by shamzz on 05/05/22.
//

import UIKit
import Chatwoot

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //initializing chatwoot SDK screens
        let chatwootVC = ChatwootController().startAConversationWithContact(email: "", name: "", avatar_url: "", custom_attributes: nil)
        chatwootVC.modalPresentationStyle = .fullScreen
        self.present(chatwootVC, animated: true, completion: nil)
    }
}

