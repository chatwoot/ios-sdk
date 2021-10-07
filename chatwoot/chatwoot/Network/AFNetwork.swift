//
//  AFNetwork.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import Foundation
import Alamofire

typealias ResponseType = Decodable
typealias AFResponse<Response: Decodable> = Alamofire.DataResponse<ApiResponse<Response>, AFError>

struct AFNetwork: NetworkService {
    
    func request<T: ResponseType>(urlRequest: URLRequest, completion: @escaping (CompletionType<T>) -> Void) {
        let urlRequest = urlRequest
        #if DEBUG
        if let bodyData = urlRequest.httpBody, let params = String(data: bodyData, encoding: .utf8) {
            print("Url:\(String(describing: urlRequest.url?.absoluteString))")
            print("Params: \(params)")
        }
        #endif
        if (NetworkReachabilityManager()!.isReachable) {
            let dataRequest = AF.request(urlRequest).responseDecodable(decoder: JSONDecoder.custom()) { (response: AFResponse<T>) in
                self.handleResponse(response, completion: completion)
            }
            
            #if DEBUG
            dataRequest.responseJSON { json in
                if let response = json.value {
                    print("Response JSON: \(response)")
                }
            }
            #endif
        }
    }
    
    func request<T: ResponseType>(url: URL, method: HTTPMethod = .get, params: [String: Any], completion: @escaping (Result<T, Error>) -> Void) {
        AF.request(url, method: method, parameters: params).responseDecodable(decoder: JSONDecoder.custom()) { (response: AFResponse<T>) in
            self.handleResponse(response, completion: completion)
        }
    }
    
    func request<Param: Encodable, T: ResponseType>(url: URL, method: HTTPMethod = .get, params: Param, completion: @escaping (Result<T, Error>) -> Void) {
        AF.request(url, method: method, parameters: params).responseDecodable(decoder: JSONDecoder.custom()) { (result: AFResponse<T>) in
            self.handleResponse(result, completion: completion)
        }
    }
    
    func requestUpload<T: ResponseType>(param params: [String: Any] ,url: String,data: [UploadData],isUpdate: Bool, completion: @escaping (CompletionType<T>) -> Void) {
        AF.upload(multipartFormData: { multipartFormData in
            
            for image in data {
                if let imgData = image.imageData {
                    multipartFormData.append(imgData, withName: image.uploadName , fileName: image.key, mimeType: "image/png")
                }
            }
            
            for (key, value) in params {
                //String
                if let temp = value as? String {
                    multipartFormData.append(temp.data(using: .utf8)!, withName: key)
                }
                //Int
                if let temp = value as? Int {
                    multipartFormData.append("\(temp)".data(using: .utf8)!, withName: key)
                }
                //Array
                if let temp = value as? NSArray {
                    temp.forEach({ element in
                        let keyObj = key + "[]"
                        if let string = element as? String {
                            multipartFormData.append(string.data(using: .utf8)!, withName: keyObj)
                        } else
                        if let num = element as? Int {
                            let value = "\(num)"
                            multipartFormData.append(value.data(using: .utf8)!, withName: keyObj)
                        }
                    })
                }
                //Dictionary
                if let temp = value as? [String: Any] {
                    do {
                        let dataAlamoDict = try JSONSerialization.data(withJSONObject: temp, options: [])
                        multipartFormData.append(dataAlamoDict, withName: key)
                    } catch {
                        
                    }
                }
            }
        },to: "\(ServerConfig().baseURL.absoluteString)\(url)", usingThreshold: UInt64.init(),method: isUpdate ? .put : .post, headers: ["Content-type": "application/x-www-form-urlencoded","Authorization": "Bearer \(GetUserDefaults.authToken)",]).responseDecodable(decoder: JSONDecoder.custom()) { (response: AFResponse<T>) in
            self.handleResponse(response, completion: completion)
        }
        
    }
    
    func handleResponse<T: ResponseType>(_ response: AFResponse<T>, completion: @escaping (CompletionType<T>) -> Void) {
        let statusCode = response.response?.statusCode ?? 0
        
        switch response.result {
        case .success(let value):
            guard value.status else {
                // Error from Server
                switch statusCode {
                case 401:
                    AppSession.logout()
                    //  NotificationCenter.default.post(name: .didUpdateRefreshToken, object: nil)
                    return
                default: break
                }
                let error = NSError(domain: "Mahamz", code: statusCode, userInfo: [NSLocalizedDescriptionKey: value.message ?? ""])
                completion(.failure(error))
                return
            }
            
            guard let result = value.data else {
                // Api success, but no result object. In this case generally `T` would be `String`
                if let message = value.message as? T {
                    completion(.success(message))
                    return
                } else {
                    if let status = value.status as? T {
                        completion(.success(status))
                    } else {
                        let errorMessage = NSLocalizedString("Something wrong happed at server", comment: "")
                        let error = NSError(domain: "AppSession.appName", code: statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        completion(.failure(error))
                    }
                }
                return
            }
            
            completion(.success(result))
            
        case .failure(let error):
            #if DEBUG
            print("API Error: \(error)")
            
            #endif
            completion(.failure(error))
            
        }
    }
}

struct AFHelper {
    
    static func jsonEncode<Parameters: Encodable>(_ parameters: Parameters?, into request: URLRequest) throws -> URLRequest {
        try JSONParameterEncoder(encoder: .custom()).encode(parameters, into: request)
    }
    
    static func urlEncode<Parameters: Encodable>(_ parameters: Parameters?, into request: URLRequest) throws -> URLRequest {
        try URLEncodedFormParameterEncoder().encode(parameters, into: request)
    }
}

struct UploadData {
    var uploadName: String
    var key: String
    var imageData: Data?
}
