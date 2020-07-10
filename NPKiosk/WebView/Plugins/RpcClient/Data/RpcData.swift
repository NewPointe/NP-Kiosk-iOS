//
//  RpcData.swift
//  NPKiosk
//
//  Created by Tyler Schrock on 5/13/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation

/// An RPC request
struct RpcRequest<T> {
    let jsonrpc: String = "2.0"
    let id: RpcIdentifier?
    let method: String
    let params: RpcParameters<T>
}
extension RpcRequest: Encodable where T: Encodable { }
extension RpcRequest: Decodable where T: Decodable { }

/// An RPC response with a result
struct RpcResponseWithResult<T> {
    let jsonrpc: String = "2.0"
    let id: RpcIdentifier
    let result: T
}
extension RpcResponseWithResult: Encodable where T: Encodable { }
extension RpcResponseWithResult: Decodable where T: Decodable { }

/// An RPC response with an error
struct RpcResponseWithError<T> where T: AnyRpcError {
    let jsonrpc: String = "2.0"
    let id: RpcIdentifier
    let error: T
}
extension RpcResponseWithError: Encodable where T: Encodable { }
extension RpcResponseWithError: Decodable where T: Decodable { }

/// Any RPC error
protocol AnyRpcError: Error {
    var code: Int { get }
    var message: String { get }
}

/// An RPC error with no additional data
struct RpcError: AnyRpcError, Codable {
    let code: Int
    let message: String
}

/// An RPC error with additional data
struct RpcErrorWithData<T>: AnyRpcError {
    let code: Int
    let message: String
    let data: T
}
extension RpcErrorWithData: Encodable where T: Encodable { }
extension RpcErrorWithData: Decodable where T: Decodable { }

/// An encodable wrapper for encoding any Encodable
struct AnyEncodable: Encodable {
    let value: Encodable
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try value.encode(to: &container)
    }
}

extension Encodable {
    func encode(to container: inout SingleValueEncodingContainer) throws {
        try container.encode(self)
    }
}
