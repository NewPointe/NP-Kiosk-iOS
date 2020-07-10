//
//  RpcParameters.swift
//  NPKiosk
//
//  Created by Tyler Schrock on 5/13/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation

/// Represents the parameters for an RPC request. Can be either an Array of positional parameters or a Dictionary of named parameters.
enum RpcParameters<T> {
    case array(Array<T>)
    case dictionary(Dictionary<String, T>)
    
    func get(atIndex index: Int) -> T? {
        if case let .array(array) = self {
            return array[index]
        }
        return nil
    }
    
    func get(withKey key: String) -> T? {
        if case let .dictionary(dictionary) = self {
            return dictionary[key]
        }
        return nil
    }
}

extension RpcParameters : Encodable where T : Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .array(array):
            try container.encode(array)
        case let .dictionary(dictionary):
            try container.encode(dictionary)
        }
    }
    func get<U>(atIndex index: Int) -> U? where U: Decodable {
        if case let .array(array) = self {
            let x = array[index]
            return try? JSONDecoder().decode(U.self, from: JSONEncoder().encode(x))
        }
        return nil
    }
}

extension RpcParameters : Decodable where T : Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let array = try? container.decode(Array<T>.self) {
            self = .array(array)
        } else if let dictionary = try? container.decode(Dictionary<String, T>.self) {
            self = .dictionary(dictionary)
        } else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Invalid JSON value.")
            )
        }
    }
}
