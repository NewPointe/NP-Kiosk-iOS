//
//  RpcIncommingRequest.swift
//  NPKiosk
//
//  Created by Tyler Schrock on 5/21/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation
import Promises

typealias RpcRequestHandler = () throws -> Promise<Encodable>?
typealias RpcRequestHandlerGenerator = (_ decoder: Decoder) throws -> RpcRequestHandler
typealias RpcRequestHandlerGeneratorCollection = Dictionary<String, RpcRequestHandlerGenerator>

struct RpcIncomingRequest: Decodable {
    let jsonrpc: String
    let id: RpcIdentifier?
    let method: String
    let handle: RpcRequestHandler
    
    static var handlerGeneratorsKey: CodingUserInfoKey {
        return CodingUserInfoKey(rawValue: "handlerGeneratorsKey")!
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.jsonrpc = try container.decode(String.self, forKey: .jsonrpc)
        self.id = try container.decodeIfPresent(RpcIdentifier.self, forKey: .id)
        self.method = try container.decode(String.self, forKey: .method)
        
        let generators = decoder.userInfo[Self.handlerGeneratorsKey] as! RpcRequestHandlerGeneratorCollection
        
        if let generator = generators[method] {
            do {
                self.handle = try generator(decoder)
            }
            catch {
                self.handle = {
                    return Promise(RpcError(code: -32602, message: "Invalid params") as Error)
                }
            }
        }
        else {
            self.handle = {
                return Promise(RpcError(code: -32601, message: "Method not found") as Error)
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case jsonrpc, id, method, params
    }
}
