//
//  Repository.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import Foundation

typealias Response<T> = (_ result: Result<T, Error>) -> Void

protocol Repository {
    var network: NetworkService { get }
    init(network: NetworkService)
}

struct HomeRouter: Repository {
    let network: NetworkService
    
    init(network: NetworkService = AFNetwork()) {
        self.network = network
    }
    
    func createConversationsApi(completion: @escaping Response<AllConversationsModel>) {
        network.request(route: HomeNetworkRouter.createAllConversations, completion: completion)
    }
    
    func listAllConversationsApi(completion: @escaping Response<[AllConversationsModel]>) {
        network.request(route: HomeNetworkRouter.listAllConversations, completion: completion)
    }
    
    func createContactApi(params: CreateContactRequest,completion: @escaping Response<CreateContactModel>) {
        network.request(route: HomeNetworkRouter.createContact(params: params), completion: completion)
    }
    
    func listAllMessagesApi(conversationID: String, completion: @escaping Response<[MessageModel]>) {
        network.request(route: HomeNetworkRouter.listAllMessages(conversationID: conversationID), completion: completion)
    }
    
    func sendTextMessageApi(conversationID: String, params: SendTextMessageModelRequest,completion: @escaping Response<MessageModel>) {
        network.request(route: HomeNetworkRouter.sendTextMessage(conversationID: conversationID, params: params), completion: completion)
    }
    
    func uploadImage(params: [String: Any],data: [UploadData],conversationID: String, completion: @escaping Response<MessageModel>) {
        let path: String = HomeNetworkRouter.uploadImage(conversationID: conversationID).path
        network.requestUpload(param: params, url: path, data: data, completion: completion)
    }
}
