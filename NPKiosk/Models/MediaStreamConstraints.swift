//
//  MediaStreamConstraints.swift
//  NPKiosk
//
//  Created by Tyler Schrock on 7/7/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation

typealias DOMString = String

// 10.3 MediaStreamConstraints

struct MediaStreamConstraints: Codable {
    let audio: BooleanOrMediaTrackConstraints
    let video: BooleanOrMediaTrackConstraints
    
    init(audio: BooleanOrMediaTrackConstraints?, video: BooleanOrMediaTrackConstraints?) {
        self.audio = audio ?? .boolean(false)
        self.video = video ?? .boolean(false)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            audio: try container.decodeIfPresent(BooleanOrMediaTrackConstraints.self, forKey: .audio),
            video: try container.decodeIfPresent(BooleanOrMediaTrackConstraints.self, forKey: .video)
        )
    }
}

enum BooleanOrMediaTrackConstraints: AutoCodableUnion {
    case boolean(Bool)
    case mediaTrackConstraints(MediaTrackConstraints)
}

// 4.3.6 MediaTrackConstraints

struct MediaTrackConstraints: Codable {
    let width: ConstrainULong?
    let height: ConstrainULong?
    let aspectRatio: ConstrainDouble?
    let frameRate: ConstrainDouble?
    let facingMode: ConstrainDOMString?
    let resizeMode: ConstrainDOMString?
    let sampleRate: ConstrainULong?
    let sampleSize: ConstrainULong?
    let echoCancellation: ConstrainBoolean?
    let autoGainControl: ConstrainBoolean?
    let noiseSuppression: ConstrainBoolean?
    let latency: ConstrainDouble?
    let channelCount: ConstrainULong?
    let deviceId: ConstrainDOMString?
    let groupId: ConstrainDOMString?
}

// 1.2 Types for Constrainable Properties

struct DoubleRange: Codable {
    let max: Double?
    let min: Double?
}

struct ConstrainDoubleRange: Codable {
    // <DoubleRange>
    let max: Double?
    let min: Double?
    // </DoubleRange>
    
    let exact: Double?
    let ideal: Double?
}

struct ULongRange: Codable {
    let max: UInt64?
    let min: UInt64?
}

struct ConstrainULongRange: Codable {
    // <ULongRange>
    let max: UInt64?
    let min: UInt64?
    // </ULongRange>
    
    let exact: UInt64?
    let ideal: UInt64?
}

struct ConstrainBooleanParameters: Codable {
    let exact: Bool?
    let ideal: Bool?
}

struct ConstrainDOMStringParameters: Codable {
    let exact: DOMStringOrDOMStringArray?
    let ideal: DOMStringOrDOMStringArray?
}

enum DOMStringOrDOMStringArray: AutoCodableUnion {
    case string(DOMString)
    case array(Array<DOMString>)
}

enum ConstrainULong: AutoCodableUnion {
    case ulong(UInt64)
    case range(ConstrainULongRange)
}

enum ConstrainDouble: AutoCodableUnion {
    case double(Double)
    case range(ConstrainDoubleRange)
}

enum ConstrainBoolean: AutoCodableUnion {
    case boolean(Bool)
    case parameters(ConstrainBooleanParameters)
}

enum ConstrainDOMString: AutoCodableUnion {
    case string(String)
    case array(Array<String>)
    case parameters(ConstrainDOMStringParameters)
}
