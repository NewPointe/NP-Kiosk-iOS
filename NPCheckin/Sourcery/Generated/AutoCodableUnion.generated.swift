// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

//
//  AutoCodableUnion.swift
//  NPKiosk
//
//  Created by Tyler Schrock on 7/8/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation

extension BooleanOrMediaTrackConstraints: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let boolean = try? container.decode(Bool.self) {
            self = .boolean(boolean)
        } else if let mediaTrackConstraints = try? container.decode(MediaTrackConstraints.self) {
            self = .mediaTrackConstraints(mediaTrackConstraints)
        } else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Invalid value")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case let .boolean(boolean):
                try container.encode(boolean)
            case let .mediaTrackConstraints(mediaTrackConstraints):
                try container.encode(mediaTrackConstraints)
        }
    }
}

extension ConstrainBoolean: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let boolean = try? container.decode(Bool.self) {
            self = .boolean(boolean)
        } else if let parameters = try? container.decode(ConstrainBooleanParameters.self) {
            self = .parameters(parameters)
        } else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Invalid value")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case let .boolean(boolean):
                try container.encode(boolean)
            case let .parameters(parameters):
                try container.encode(parameters)
        }
    }
}

extension ConstrainDOMString: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode(Array<String>.self) {
            self = .array(array)
        } else if let parameters = try? container.decode(ConstrainDOMStringParameters.self) {
            self = .parameters(parameters)
        } else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Invalid value")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case let .string(string):
                try container.encode(string)
            case let .array(array):
                try container.encode(array)
            case let .parameters(parameters):
                try container.encode(parameters)
        }
    }
}

extension ConstrainDouble: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let range = try? container.decode(ConstrainDoubleRange.self) {
            self = .range(range)
        } else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Invalid value")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case let .double(double):
                try container.encode(double)
            case let .range(range):
                try container.encode(range)
        }
    }
}

extension ConstrainULong: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let ulong = try? container.decode(UInt64.self) {
            self = .ulong(ulong)
        } else if let range = try? container.decode(ConstrainULongRange.self) {
            self = .range(range)
        } else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Invalid value")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case let .ulong(ulong):
                try container.encode(ulong)
            case let .range(range):
                try container.encode(range)
        }
    }
}

extension DOMStringOrDOMStringArray: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(DOMString.self) {
            self = .string(string)
        } else if let array = try? container.decode(Array<DOMString>.self) {
            self = .array(array)
        } else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Invalid value")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case let .string(string):
                try container.encode(string)
            case let .array(array):
                try container.encode(array)
        }
    }
}

extension JsonValue: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let array = try? container.decode(Array<JsonValue>.self) {
            self = .array(array)
        } else if let object = try? container.decode(Dictionary<String, JsonValue>.self) {
            self = .object(object)
        } else if container.decodeNil() {
            self = .null
        } else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Invalid value")
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
            case let .bool(bool):
                try container.encode(bool)
            case let .array(array):
                try container.encode(array)
            case let .object(object):
                try container.encode(object)
            case .null:
                try container.encodeNil()
        }
    }
}

