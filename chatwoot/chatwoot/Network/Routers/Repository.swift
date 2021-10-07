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
    
    func getTermsApi(completion: @escaping Response<String>) {
        network.request(route: HomeNetworkRouter.termsAndConditions, completion: completion)
    }
    
    func switchAccountApi(params: SwitchAccountRequest,completion: @escaping Response<SwitchAccountModel>) {
        network.request(route: HomeNetworkRouter.switchAccount(params: params), completion: completion)
    }
}
