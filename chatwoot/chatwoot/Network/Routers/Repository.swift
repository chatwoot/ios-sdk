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
    
    func listAllConversationsApi(completion: @escaping Response<[AllConversationsModel]>) {
        network.request(route: HomeNetworkRouter.listAllConversations, completion: completion)
    }
    
    func createContactApi(params: CreateContactRequest,completion: @escaping Response<CreateContactModel>) {
        network.request(route: HomeNetworkRouter.createContact(params: params), completion: completion)
    }
}
