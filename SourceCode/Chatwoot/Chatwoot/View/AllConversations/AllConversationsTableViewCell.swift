//
//  AllConversationsTableViewCell.swift
//  chatwoot
//
//  Created by shamzz on 01/11/21.
//

import UIKit

class AllConversationsTableViewCell: UITableViewCell {
    static let id = String(describing: AllConversationsTableViewCell.self)

    @IBOutlet weak var lblAgent  : UILabel!
    @IBOutlet weak var lblMessage : UILabel!
    @IBOutlet weak var lblDate    : UILabel!
    @IBOutlet weak var lblCount   : PaddingLabel!
    @IBOutlet weak var rightNavigation: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblCount.layer.masksToBounds = true
        lblCount.layer.cornerRadius = (lblCount.frame.height/2)
        
        rightNavigation.tintColor = GetUserDefaults.getPrimaryColor()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.lblCount.layer.cornerRadius = (self.lblCount.frame.height/2)
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lblCount.layer.cornerRadius = (lblCount.frame.height/2)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(conversationsModel: AllConversationsModel) {
        lblCount.text = String(format: "%@", getUnreadMessageCount(conversationsModel: conversationsModel).roundedWithAbbreviations)
        lblCount.layer.cornerRadius = (lblCount.frame.height/2)
        //FIXME:- Agent name
        if 0 == conversationsModel.messages.count {
            lblAgent.text = conversationsModel.contact.contactName
            lblMessage.text = Constants.Messages.noMessagesFound
            lblDate.text = conversationsModel.contact.lastActivityAt.utcToLocal().relativeTime
        }
        else {
            let lastMessage: MessageModel = conversationsModel.messages.last!
            lblAgent.text = lastMessage.sender?.senderName
            let createdAt = Date(timeIntervalSince1970: lastMessage.createdAt)
            lblDate.text = createdAt.relativeTime
            
            if (lastMessage.attachments?.count ?? 0 > 0) {
                for attachment in lastMessage.attachments {
                    if attachment.fileType == "audio" {
                        lblMessage.text = Constants.Messages.audioMessage
                    }
                    else if attachment.fileType == "image" {
                        lblMessage.text = Constants.Messages.picMessage
                    }
                    else {
                        lblMessage.text = Constants.Messages.fileMessage
                    }
                }
            }
            else {
                if (lastMessage.content != nil) {
                    lblMessage.text = lastMessage.content
                }
                else {
                    lblMessage.text = Constants.Messages.noContentFound
                }
            }
        }
    }
    
    func getUnreadMessageCount(conversationsModel: AllConversationsModel)-> Int {
        let messageModels = conversationsModel.messages.filter { messageModel in
            return messageModel.createdAt * 1000 > conversationsModel.agentLastSeenAt * 1000 &&
            messageModel.messageType == 0 &&
            messageModel.isPrivate != true
        }
        return messageModels.count
    }
}
