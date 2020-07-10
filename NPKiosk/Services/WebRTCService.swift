//
//  WebRTCService.swift
//  NPKiosk
//
//  Created by Tyler Schrock on 6/22/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation
import WebRTC
import Promises
import os.log

class WebRTCService: NSObject, ObservableObject {
    
    let queue = DispatchQueue(label: "org.newpointe.kiosk.webrtcqueue")
    
    private var videoEncoderFactory: RTCDefaultVideoEncoderFactory! = nil
    private var videoDecoderFactory: RTCDefaultVideoDecoderFactory! = nil
    private var peerConnectionFactory: RTCPeerConnectionFactory! = nil
    
    override init() {
        super.init()
        queue.sync {
            os_log("Initializing RTC", type: .debug)
            RTCInitializeSSL()
            RTCSetupInternalTracer()
            RTCSetMinDebugLogLevel(.warning)
            videoEncoderFactory = RTCDefaultVideoEncoderFactory()
            videoDecoderFactory = RTCDefaultVideoDecoderFactory()
            peerConnectionFactory = RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
        }
    }
    
    deinit {
        queue.sync {
            os_log("Shutting down RTC", type: .debug)
            RTCShutdownInternalTracer();
            RTCCleanupSSL()
            peerConnectionFactory = nil
            videoEncoderFactory = nil
            videoDecoderFactory = nil
        }
    }
    
    func peerConnection(with configuration: RTCConfiguration, constraints: RTCMediaConstraints, delegate: RTCPeerConnectionDelegate?) -> RTCPeerConnection {
        return queue.sync {
            return self.peerConnectionFactory.peerConnection(with: configuration, constraints: constraints, delegate: delegate)
        }
    }
    
    func videoSource() -> RTCVideoSource {
        return queue.sync {
            return self.peerConnectionFactory.videoSource()
        }
    }
    
    func videoTrack(with source: RTCVideoSource, trackId: String) -> RTCVideoTrack {
        return queue.sync {
            return self.peerConnectionFactory.videoTrack(with: source, trackId: trackId)
        }
    }
}
