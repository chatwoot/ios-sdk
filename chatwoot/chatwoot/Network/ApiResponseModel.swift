//
//  ApiResponseModel.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import Foundation

struct ApiResponse<T: Decodable>: Decodable {
    let status: Bool
    let message: String?
    let data: T?
}

extension ApiResponse {
    init(data: Data) throws {
        self = try JSONDecoder.custom().decode(ApiResponse.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "AppSession.appName", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        success: Bool? = nil,
        message: String? = nil,
        result: T? = nil
    ) -> ApiResponse {
        return ApiResponse(
            status: success ?? self.status,
            message: message ?? self.message,
            data: result ?? self.data
        )
    }
}
