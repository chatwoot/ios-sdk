//
//  AllConversationsViewController.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit

class AllConversationsViewController: UIViewController {
    
    @IBOutlet weak var allConversationsTableView: UITableView!

    private var allConversationsViewModel = AllConversationsViewModel()
    
    var allConversations: [AllConversationsModel]! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        handleAPICalls()
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
}

extension AllConversationsViewController: AllConversationsDelegate {
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

extension AllConversationsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AllConversationsTableViewCell.id, for: indexPath) as! AllConversationsTableViewCell
        cell.configureCell(conversationsModel: allConversations[indexPath.row])
        return cell
    }
}

extension AllConversationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversationsModel: AllConversationsModel = allConversations[indexPath.row]
        if 0 < conversationsModel.messages.count {
            let conversationDetailsVC = UIStoryboard.Main.conversationDetailsVC() as! ConversationDetailsViewController
            conversationDetailsVC.modalPresentationStyle = .fullScreen
            conversationDetailsVC.modalTransitionStyle = .crossDissolve
            conversationDetailsVC.selectedConversation = conversationsModel
            self.present(conversationDetailsVC, animated: true, completion: nil)
        }
    }
}
