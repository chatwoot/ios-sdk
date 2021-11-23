//
//  NetworkService.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import Foundation
import Alamofire
public typealias CompletionType<Response> = Result<Response, Error>

protocol NetworkService {
    func request<Response: ResponseType>(urlRequest: URLRequest, completion: @escaping (Result<Response, Error>) -> Void)
    func requestUpload<Response: ResponseType>(param: [String: Any],url: String,data: [UploadData],isUpdate: Bool,completion: @escaping (Result<Response, Error>) -> Void)
}

extension NetworkService {
    func request<Response: ResponseType>(route: Router, completion: @escaping (Result<Response, Error>) -> Void) {
        // swiftlint:disable force_try
        let urlRequest = try! route.asURLRequest()
        request(urlRequest: urlRequest, completion: completion)
    }
    
    func requestUpload<Response: ResponseType>(param: [String: Any],url: String,data: [UploadData],isUpdate: Bool,completion: @escaping (Result<Response, Error>) -> Void) {
        requestUpload(param: param, url: url, data: data, isUpdate: isUpdate, completion: completion)
    }
}
