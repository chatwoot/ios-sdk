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
    
    var selectedConversation: AllConversationsModel! = nil

    private var conversationDetailsViewModel = ConversationDetailsViewModel()
    
    var allMessages: [MessageModel]! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        //FIXME:- AgentName
        let lastMessage: MessageModel = selectedConversation.messages.last!
        lblAgentName.text = lastMessage.sender.senderName
        
        handleAPICalls()
    }
    
    func handleAPICalls() {
        conversationDetailsViewModel.delegate = self
        conversationDetailsViewModel.listAllMessagesApi()
    }
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension ConversationDetailsViewController: ConversationDetailsDelegate {
    func listAllMessages(data: [MessageModel]) {
        print(data)
    }
    
    func networkOfflineAlert() {
        self.showInternetOfflineToast()
    }
}

