//
//  IncommingRpcMessage.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 5/13/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation

/// An incoming RPC message.
enum RpcIncomingMessage: Decodable {
    case request(RpcIncomingRequest)
    case result(RpcResponseWithResult<JsonValue>)
    case error(RpcResponseWithError<RpcErrorWithData<JsonValue>>)

    init(from decoder: Decoder) throws {
        let containerKeys = try decoder.container(keyedBy: CodingKeys.self)
        let container = try decoder.singleValueContainer()
        if containerKeys.contains(.method), let request = try? container.decode(RpcIncomingRequest.self) {
            self = .request(request)
        }
        else if containerKeys.contains(.result), let result = try? container.decode(RpcResponseWithResult<JsonValue>.self) {
            self = .result(result)
        }
        else if containerKeys.contains(.error), let error = try? container.decode(RpcResponseWithError<RpcErrorWithData<JsonValue>>.self) {
            self = .error(error)
        }
        else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Invalid JSON value.")
            )
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case method, result, error
    }
}
