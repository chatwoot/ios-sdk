//
//  ConversationDetailsViewController.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit

class ConversationDetailsViewController: UIViewController {
    
    @IBOutlet weak var lblAgentName: UILabel!
    
    @IBOutlet weak var allMessagesCollectionView: UICollectionView!

    var conversationsModel: AllConversationsModel! = nil

    private var allConversationsViewModel = AllConversationsViewModel()
    
    var allConversations: [AllConversationsModel]! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        //FIXME:- AgentName
        let lastMessage: MessagesModel = conversationsModel.messages.last!
        lblAgentName.text = lastMessage.sender.senderName
        
        handleAPICalls()
    }
    
    func handleAPICalls() {
        //allConversationsViewModel.delegate = self
        if GetUserDefaults.contactInfo == nil {
            allConversationsViewModel.createContactApi()
        }
        else {
            allConversationsViewModel.listAllConversationsApi()
        }
    }
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
