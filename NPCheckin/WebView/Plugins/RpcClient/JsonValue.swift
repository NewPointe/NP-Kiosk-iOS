//
//  JsonValue.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 5/13/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation

/// Represents a generic JSON value. Can be a String, Number (Int or Double), Boolean, Array, Dictionary, or Null
enum JsonValue: AutoCodableUnion {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array(Array<JsonValue>)
    case object(Dictionary<String, JsonValue>)
    case null
    
    func asString() -> String? {
        if case let .string(string) = self {
            return string
        }
        return nil
    }
    
    
}

protocol JsonValueType {
    init?(fromJsonValue: JsonValue)
}

extension Int: JsonValueType {
    init?(fromJsonValue jsonValue: JsonValue) {
        if case let .int(int) = jsonValue {
            self = int
            return
        }
        return nil
    }
}

extension String: JsonValueType {
    init?(fromJsonValue jsonValue: JsonValue) {
        if case let .string(string) = jsonValue {
            self = string
            return
        }
        return nil
    }
}

extension Bool: JsonValueType {
    init?(fromJsonValue jsonValue: JsonValue) {
        if case let .bool(bool) = jsonValue {
            self = bool
            return
        }
        return nil
    }
}
