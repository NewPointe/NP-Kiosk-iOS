//
//  CustomStringConvertible.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 7/9/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation
import WebRTC

extension RTCSignalingState: CustomStringConvertible {
    public var description: String {
        switch self {
            case .closed: return "closed"
            case .haveLocalOffer: return "haveLocalOffer"
            case .haveLocalPrAnswer: return "haveLocalPrAnswer"
            case .haveRemoteOffer: return "haveRemoteOffer"
            case .haveRemotePrAnswer: return "haveRemotePrAnswer"
            case .stable: return "stable"
            default: return "unknown"
        }
    }
}

extension RTCIceConnectionState: CustomStringConvertible {
    public var description: String {
        switch self {
            case .checking: return "checking"
            case .closed: return "closed"
            case .completed: return "completed"
            case .connected: return "connected"
            case .count: return "count"
            case .disconnected: return "disconnected"
            case .failed: return "failed"
            case .new: return "new"
            default: return "unknown"
        }
    }
}

extension RTCIceGatheringState: CustomStringConvertible {
    public var description: String {
        switch self {
            case .complete: return "complete"
            case .gathering: return "gathering"
            case .new: return "new"
            default: return "unknown"
        }
    }
}

extension AVCaptureDevice.DeviceType: CustomStringConvertible {
    public var description: String {
        switch self {
            case .builtInDualCamera: return "builtInDualCamera"
            case .builtInDualWideCamera: return "builtInDualWideCamera"
            case .builtInMicrophone: return "builtInMicrophone"
            case .builtInTelephotoCamera: return "builtInTelephotoCamera"
            case .builtInTripleCamera: return "builtInTripleCamera"
            case .builtInTrueDepthCamera: return "builtInTrueDepthCamera"
            case .builtInUltraWideCamera: return "builtInUltraWideCamera"
            case .builtInWideAngleCamera: return "builtInWideAngleCamera"
            default: return "unknown"
        }
    }
}

extension AVCaptureDevice.Position: CustomStringConvertible {
    init?(value: String?) {
        switch value {
            case "front": self = .front
            case "back": self = .back
            case "unspecified": self = .unspecified
            default: return nil
        }
    }
    
    public var description: String {
        switch self {
            case .back: return "back"
            case .front: return "front"
            case .unspecified: return "unspecified"
            default: return "unknown"
        }
    }
}
