//
//  ConversationsViewController.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit

public class ConversationsViewController: UIViewController {
    
    @IBOutlet weak var headerContainerView: UIView!

    @IBOutlet weak var allConversationsTableView: UITableView!

    private var allConversationsViewModel = AllConversationsViewModel()
    
    var allConversations: [AllConversationsModel]! = nil

    /// The `webSocketTask` receives the realtime chats while app is active
    var webSocketTask: URLSessionWebSocketTask? = nil

    public init(with email: String, name: String, avatar_url:String, custom_attributes: Dictionary<String, String>!) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        configurePrimaryColor()
        configureTableView()
        handleAPICalls()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.connectSocket()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(appTerminateNotify), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        configurePrimaryColor()
    }
    
    @IBAction func newConversationClicked(_sender : AnyObject) {
        let conversationDetailsVC = ConversationDetailsViewController()
        self.navigationController?.pushViewController(conversationDetailsVC, animated: true)
    }
    
    func configurePrimaryColor() {
        self.view.backgroundColor = GetUserDefaults.getPrimaryColor()
        headerContainerView.backgroundColor = GetUserDefaults.getPrimaryColor()
    }
    
    func configureTableView() {
        allConversationsTableView.delegate = nil
        allConversationsTableView.dataSource = nil
        allConversationsTableView.tableFooterView = UIView.init(frame: CGRect.zero)
        allConversationsTableView.refreshControl = refreshControl
    }
    
    func handleAPICalls() {
        allConversationsViewModel.delegate = self
        if GetUserDefaults.contactInfo == nil {
            allConversationsViewModel.createContactApi()
        }
        else {
            allConversationsViewModel.listAllConversationsApi()
        }
    }
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshConversations), for: .valueChanged)
        return control
    }()
    
    @objc func refreshConversations() {
        allConversationsViewModel.listAllConversationsApi()
    }
    
    func connectSocket() {
        let urlSession = URLSession(configuration: .default)
        webSocketTask = urlSession.webSocketTask(with: ServerConfig().socketURL)
        webSocketTask?.resume()
        
        print(GetUserDefaults.contactInfo.pubsubToken ?? "")
        let pubsTokenDict = ["channel": "RoomChannel", "pubsub_token": GetUserDefaults.contactInfo.pubsubToken]
        let encoder = JSONEncoder()
        if let pubsTokenData = try? encoder.encode(pubsTokenDict) {
            if let pubsTokenJson = String(data: pubsTokenData, encoding: .utf8) {
                let paramDict = ["command": "subscribe", "identifier":pubsTokenJson]
                if let paramJsonData = try? encoder.encode(paramDict) {
                    if let paramJson = String(data: paramJsonData, encoding: .utf8) {
                        let message = URLSessionWebSocketTask.Message.string(paramJson)
                        webSocketTask?.send(message) { error in
                            if let error = error {
                                print("WebSocket sending error: \(error)")
                            }
                        }
                        receiveSocketMessages()
                    }
                }
            }
        }
    }
    
    func receiveSocketMessages() {
        webSocketTask?.receive { [self] result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received string: \(text)")
                    processAndDisplaySocketMessage(jsonMessage: text)
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    print("Received default data:")
                }
            }
            
            //Recursive call to fetch the live messages
            self.receiveSocketMessages()
        }
    }
    
    func processAndDisplaySocketMessage(jsonMessage: String) {
        do {
            let msgModel = try JSONDecoder().decode(SocketMessageModel.self, from: jsonMessage.data(using: .utf8)!)
            if let messageSocketData = msgModel.messageSocketData {
                if let msgItem = messageSocketData.message {
                    if msgItem.messageID != nil {
                        
                        guard msgItem.sender != nil else {return}
                        
                        //getting the conversation object.
                        let coversationList = self.allConversations.filter { convModel in
                            return convModel.conversationID == msgItem.conversationID
                        }
                        
                        //avoiding sender duplicate messages.
                        if let contactInfo = GetUserDefaults.contactInfo {
                            if (contactInfo.contactID == msgItem.sender.senderID && coversationList.count > 0) {
                                return
                            }
                        }
                        
                        if coversationList.count > 0 {
                            var conversationModel: AllConversationsModel = coversationList.first!

                            //avoiding duplicates
                            let messageNotExists = conversationModel.messages.filter { msgModel in
                                return msgModel.messageID == msgItem.messageID
                            }.count == 0
                            
                            if true == messageNotExists {
                                //indexpath to replace
                                let indexToReplace = self.allConversations.firstIndex(of: conversationModel)
                                let indexPath = NSIndexPath.init(row: indexToReplace!, section: 0)

                                conversationModel.messages.append(msgItem)
                                self.allConversations[indexToReplace!] = conversationModel
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    self.allConversationsTableView.beginUpdates()
                                    self.allConversationsTableView.reloadRows(at: [indexPath as IndexPath], with: .none)
                                    self.allConversationsTableView.endUpdates()
                                    
                                    if (self.navigationController?.children.last is ConversationDetailsViewController) {
                                        let convDetailsVC:ConversationDetailsViewController  = self.navigationController?.children.last as! ConversationDetailsViewController
                                        convDetailsVC.insertMessageFromSocket(messageModel: msgItem)
                                    }
                                }
                            }
                            else {
                                print("Duplicate message received from the socket")
                            }
                        }
                    }
                }
            }
                
        } catch {
            // print error here.
        }
    }
    
    @objc func appTerminateNotify() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}

extension ConversationsViewController: AllConversationsDelegate {
    func contactCreated(data: CreateContactModel) {
        allConversationsViewModel.listAllConversationsApi()
    }
    func listAllConversations(data: [AllConversationsModel]) {
        allConversations = data
        allConversationsTableView.delegate = self
        allConversationsTableView.dataSource = self
        allConversationsTableView.reloadData()
        refreshControl.endRefreshing()
    }
    func networkOfflineAlert() {
        self.showInternetOfflineToast()
    }
}

extension ConversationsViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let allConversationsList = allConversations {
            if allConversationsList.count == 0 {
                tableView.setEmptyMessage(Constants.Messages.noConversationFound)
            } else {
                tableView.resetBackgroundView()
            }
            return allConversationsList.count;
        }
        else {
            tableView.setEmptyMessage(Constants.Messages.noConversationFound)
            return 0;
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AllConversationsTableViewCell.id, for: indexPath) as! AllConversationsTableViewCell
        cell.configureCell(conversationsModel: allConversations[indexPath.row])
        return cell
    }
}

extension ConversationsViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversationsModel: AllConversationsModel = allConversations[indexPath.row]
        let conversationDetailsVC = ConversationDetailsViewController()
        conversationDetailsVC.selectedConversation = conversationsModel
        self.navigationController?.pushViewController(conversationDetailsVC, animated: true)

    }
}
