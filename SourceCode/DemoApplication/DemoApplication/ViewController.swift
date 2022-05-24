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
<<<<<<< HEAD
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //let chatwootVC: ConversationsViewController = ConversationsViewController(with: "", name: "", avatar_url: "", custom_attributes: nil)
        
        let storyboardName = "Main"
        let storyboardBundle = Bundle(for: ConversationsViewController.self)
        let storyboardChatwoot: UIStoryboard = UIStoryboard(name: storyboardName, bundle: storyboardBundle)
        let chatwootVC = storyboardChatwoot.instantiateViewController(withIdentifier: "ChatwootNavigation")
        chatwootVC.modalPresentationStyle = .fullScreen
        self.present(chatwootVC, animated: true, completion: nil)
    }
=======

        let ChatwootVC = ChatwootViewController()
    }


>>>>>>> caf2454ee5f6b0815e7a0e7dc6bc346ac57a33f9
}

