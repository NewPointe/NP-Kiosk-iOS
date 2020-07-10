//
//  RpcIdentifier.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 5/13/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation

/// Represents an RPC identifier. Can be a String, Number (Int or Double), or Null.
enum RpcIdentifier: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case null
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if container.decodeNil() {
            self = .null
        } else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Invalid JSON value.")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(string):
            try container.encode(string)
        case let .int(int):
            try container.encode(int)
        case let .double(double):
            try container.encode(double)
        case .null:
            try container.encodeNil()
        }
    }
}
