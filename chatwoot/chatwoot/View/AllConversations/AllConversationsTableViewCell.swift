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
    @IBOutlet weak var lblCount   : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblCount.layer.masksToBounds = true
        lblCount.layer.cornerRadius = (lblCount.frame.height/2)
        
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
        lblCount.text = String(format: "  %@  ", conversationsModel.messages.count.roundedWithAbbreviations)
        lblCount.layer.cornerRadius = (lblCount.frame.height/2)
        //FIXME:- Agent name
        if 0 == conversationsModel.messages.count {
            lblAgent.text = conversationsModel.contact.contactName
            lblMessage.text = Constants.Messages.noMessagesFound
            lblDate.text = conversationsModel.contact.lastActivityAt.utcToLocal().relativeTime
        }
        else {
            let lastMessage: MessagesModel = conversationsModel.messages.last!
            lblAgent.text = lastMessage.sender.senderName
            lblMessage.text = lastMessage.content
            let createdAt = Date(timeIntervalSince1970: lastMessage.createdAt)
            lblDate.text = createdAt.relativeTime
        }
    }
}
