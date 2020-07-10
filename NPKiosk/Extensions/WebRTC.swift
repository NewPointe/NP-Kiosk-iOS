//
//  WebRTC.swift
//  NPKiosk
//
//  Created by Tyler Schrock on 5/22/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation
import WebRTC

enum SdpType: String, Codable {
    case offer, prAnswer, answer
    
    var value: RTCSdpType {
        switch self {
        case .offer:    return .offer
        case .answer:   return .answer
        case .prAnswer: return .prAnswer
        }
    }
}

struct SessionDescription: Codable {
    let sdp: String
    let type: SdpType
    
    init(_ sdp: RTCSessionDescription) {
        self.sdp = sdp.sdp
        
        switch sdp.type {
            case .offer:    self.type = .offer
            case .prAnswer: self.type = .prAnswer
            case .answer:   self.type = .answer
        @unknown default:
            fatalError("Unknown sdp type")
        }
    }
    
    var value: RTCSessionDescription {
        return RTCSessionDescription(type: self.type.value, sdp: self.sdp)
    }
}

struct IceCandidate: Codable {
    let candidate: String
    let sdpMLineIndex: Int32
    let sdpMid: String?
    
    init(_ candidate: RTCIceCandidate) {
        self.candidate = candidate.sdp
        self.sdpMLineIndex = candidate.sdpMLineIndex
        self.sdpMid = candidate.sdpMid
    }
    
    var value: RTCIceCandidate {
        return RTCIceCandidate(sdp: self.candidate, sdpMLineIndex: self.sdpMLineIndex, sdpMid: self.sdpMid)
    }
}
