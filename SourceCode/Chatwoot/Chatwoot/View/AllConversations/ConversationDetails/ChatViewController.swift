//
//  ChatViewController.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//


import UIKit

/// A base class for the example controllers
class ChatViewController: MessagesViewController {

    // MARK: - Public properties
    public var selectedConversation: AllConversationsModel! = nil

    /// The `AudioController` control the AVAudioPlayer state (play, pause, stop) and update audio cell UI accordingly.
    lazy var audioController = AudioController(messageCollectionView: messagesCollectionView)
        
    public lazy var messageList: [MockMessage] = []

    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        return control
    }()

    // MARK: - Private properties
    
    private var conversationDetailsViewModel = ConversationDetailsViewModel()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageCollectionView()
        configureMessageInputBar()
        title = "Chatwoot"
        conversationDetailsViewModel.delegate = self
        
        if selectedConversation == nil {
            conversationDetailsViewModel.createConversationsApi()
        }
        else {
            conversationDetailsViewModel.listAllMessagesApi(conversationID: String(selectedConversation.conversationID))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioController.stopAnyOngoingPlaying()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func loadMoreMessages() {
        self.refreshControl.endRefreshing()
    }
    
    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        showMessageTimestampOnSwipeLeft = true // default false
        messagesCollectionView.refreshControl = refreshControl
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.primaryColor.withAlphaComponent(0.3),
            for: .highlighted
        )
    }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: MockMessage) {
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {

        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    public func sendImageToAPI(imageData: UploadData) {
        conversationDetailsViewModel.sendImageAPI(params: [String : Any](), data: [imageData], conversationID: String(selectedConversation.conversationID))
    }
}

// MARK: - MessagesDataSource
extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return MockUser(senderId: String(GetUserDefaults.contactInfo.contactID), displayName:GetUserDefaults.contactInfo.contactName)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.init(name: "HelveticaNeueeTextPro-Bold", size: 10) as Any, NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = message.sentDate.utcToLocalString().utcToLocal().relativeTimeForChat
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    func textCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell? {
        return nil
    }
}

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
        
        if cell is LinkPreviewMessageCell {
            let indexPath:IndexPath = messagesCollectionView.indexPath(for: cell)!
            let mockMessage: MockMessage = messageList[indexPath.section]
            
            guard let url = URL(string: mockMessage.itemLink) else {
                return
            }
                
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("Image tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }

    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                print("Failed to identify message when audio cell receive tap gesture")
                return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }

    func didStartAudio(in cell: AudioMessageCell) {
        print("Did start playing audio sound")
    }

    func didPauseAudio(in cell: AudioMessageCell) {
        print("Did pause audio sound")
    }

    func didStopAudio(in cell: AudioMessageCell) {
        print("Did stop audio sound")
    }

    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }

}

// MARK: - MessageLabelDelegate

extension ChatViewController: MessageLabelDelegate {
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }

    func didSelectHashtag(_ hashtag: String) {
        print("Hashtag selected: \(hashtag)")
    }

    func didSelectMention(_ mention: String) {
        print("Mention selected: \(mention)")
    }

    func didSelectCustom(_ pattern: String, match: String?) {
        print("Custom data detector patter selected: \(pattern)")
    }
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {

    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        processInputBar(messageInputBar)
    }

    func processInputBar(_ inputBar: InputBarAccessoryView) {
        // Here we can parse for which substrings were autocompleted
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in

            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }

        let components = inputBar.inputTextView.components
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        // Resign first responder for iPad split view
        inputBar.inputTextView.resignFirstResponder()
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa"
                self?.insertMessages(components)
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }

    private func insertMessages(_ data: [Any]) {
        for component in data {
            let user = SampleData.shared.currentSender
            if let str = component as? String {
                conversationDetailsViewModel.sendTextMessageApi(conversationID: String(selectedConversation.conversationID), textMessage: str)
            } else if let img = component as? UIImage {
                let message = MockMessage(image: img, user: user, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            }
        }
    }
}

extension ChatViewController: ConversationDetailsDelegate {
    func createConversations(data: AllConversationsModel) {
        selectedConversation = data;
        conversationDetailsViewModel.listAllMessagesApi(conversationID: String(selectedConversation.conversationID))
        if self.navigationController?.children.first is ConversationsViewController {
            let allConversationVC: ConversationsViewController = self.navigationController?.children.first as! ConversationsViewController
            allConversationVC.refreshConversations()
        }
    }
    
    func listAllMessages(data: [MessageModel]) {
        var message: MockMessage? = nil
        for messageModel in data {
            let sender = MockUser(senderId: String(messageModel.sender.senderID), displayName: messageModel.sender.senderName, userImage:messageModel.sender.thumbnail)
            let messageID = String(messageModel.messageID)
            let messageDate = Date(timeIntervalSince1970: messageModel.createdAt)

            if (messageModel.attachments?.count ?? 0 > 0) {
                for attachment in messageModel.attachments {
                    if attachment.fileType == "audio" {
                        let audioURL = URL(string: attachment.dataURL)
                        message = MockMessage(audioURL: audioURL!, user: sender, messageId:messageID , date: messageDate)
                    }
                    else if attachment.fileType == "image" {
                        let imageURL: URL = URL(string: attachment.thumbURL)!
                        message = MockMessage(imageURL: imageURL, user: sender, messageId:messageID , date: messageDate)
                    }
                    else {
                        let linkItem = MockLinkItem(
                            text: Constants.Messages.fileMessage,
                            attributedText: nil,
                            url: URL(string: attachment.dataURL)!,
                            title: "Click the link to view",
                            teaser: attachment.dataURL,
                            thumbnailImage: UIImage(named: "file_message")!
                        )
                        message = MockMessage(linkItem: linkItem, user: sender, messageId: messageID, date: messageDate)
                    }
                }
            }
            else {
                if (messageModel.content != nil) {
                    message = MockMessage(text: messageModel.content, user: sender, messageId: messageID, date: messageDate)
                }
                else {
                    message = MockMessage(text: Constants.Messages.noContentFound, user: sender, messageId: messageID, date: messageDate)
                }
            }
            
            //insert and update the message.
            if let chatMessage = message {
                self.insertMessage(chatMessage)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.messagesCollectionView.scrollToLastItem()
        }
        
        print(data)
    }
    
    func textMessageDelivered(data: MessageModel) {
        let sender = MockUser(senderId: String(data.sender.senderID), displayName: data.sender.senderName, userImage:data.sender.thumbnail)
        let messageID = String(data.messageID)
        let message = MockMessage(text: data.content, user: sender, messageId: messageID, date: Date().addingTimeInterval(-2))
        self.insertMessage(message)

        print(data)
    }
    
    func imageMessageDelivered(data: MessageModel) {
        print(data)
    }

    func networkOfflineAlert() {
        self.showInternetOfflineToast()
    }
}
