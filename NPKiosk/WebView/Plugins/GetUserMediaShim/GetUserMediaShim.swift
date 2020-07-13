//
//  WebViewSignalingClient.swift
//  NPKiosk
//
//  Created by Tyler Schrock on 5/12/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation
import WebRTC
import WebKit
import Promises
import os.log

struct StartSessionResponse: Codable {
    let sessionId: String
    let rtcSessionDescription: SessionDescription
}


/// A shim that adds the `MediaDevices.getUserMedia()` API to a `WKWebView`
final class GetUserMediaShim: NSObject, UserMediaSessionDelegate {
    
    /// The `RpcClient` to use to communicate with the `WKWebView`
    private weak var rpcClient: RpcClient?
    
    /// The `WebRTCService` to use to coordinate WebRTC actions
    private weak var webRTCService: WebRTCService?
    
    /// A list of all active media sessions
    private var mediaSessions = Dictionary<String, UserMediaSession>()
    
    /// Creates a new `GetUserMediaShim` and applies it to the given `WKWebView`
    /// - Parameters:
    ///   - webView: The `WKWebView` to shim
    ///   - rpcClient: The `RpcClient` to use
    ///   - webRTCService: The `WebRTCService` to use
    init(webView: WKWebView, rpcClient: RpcClient, webRTCService: WebRTCService) {
        self.rpcClient = rpcClient
        self.webRTCService = webRTCService
        super.init()
        
        // Register the RPC handlers
        rpcClient.registerMethod("GetUserMediaShim.native.connectCamera", self.rpcConnectCamera)
        rpcClient.registerMethod("GetUserMediaShim.native.answer", self.rpcAnswer)
        rpcClient.registerMethod("GetUserMediaShim.native.candidate", self.rpcCandidate)
        
        // Register the client script
        if let contents = String(contentsOfResource: "GetUserMediaShim", ofType: "js") {
            webView.configuration.userContentController.addUserScript(WKUserScript(
                source: contents,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: true
            ))
        }
    }
    
    private func getOrCreateMediaSession(mediaSessionId: String) -> UserMediaSession {
        if let mediaSession = self.mediaSessions[mediaSessionId] {
            return mediaSession
        }
        else {
            let mediaSession = UserMediaSession(id: mediaSessionId, webRTCService: self.webRTCService!, delegate: self)
            self.mediaSessions[mediaSessionId] = mediaSession
            return mediaSession
        }
    }
    
    private func rpcConnect(mediaSessionId: String, constraints: MediaStreamConstraints) -> Promise<SessionDescription> {
        os_log("Recieved request to start camera", type: .debug)
        return Promise { resolve, reject in
            let mediaSession = self.getOrCreateMediaSession(mediaSessionId: mediaSessionId)
            mediaSession.createOffer().then { offer in
                mediaSession.setLocalDescription(localSdp: offer).then {
                    resolve(SessionDescription(offer))
                }
            }
        }
    }
    
    private func rpcAnswer(mediaSessionId: String, answer: SessionDescription) -> Promise<Bool>? {
        os_log("Recieved an answer", type: .debug)
        if let mediaSession = self.mediaSessions[mediaSessionId] {
            _ = mediaSession.setRemoteDescription(remoteSdp: answer.value)
        }
    }
    
    private func rpcCandidate(mediaSessionId: String, candidate: IceCandidate) -> Promise<Bool>? {
        os_log("Recieved an ICE Candidate", type: .debug)
        if let mediaSession = self.mediaSessions[mediaSessionId] {
            mediaSession.add(candidate: candidate.value)
        }
        return nil
    }
    
    func mediaSession(_ mediaSession: UserMediaSession, didGenerate candidate: RTCIceCandidate) {
        os_log("Forwarding local candidate", type: .debug)
        let params = RpcParameters<AnyEncodable>.array([
            AnyEncodable(value: mediaSession.id),
            AnyEncodable(value: IceCandidate(candidate))
        ])
        try? self.rpcClient?.sendNotification(method: "GetUserMediaShim.javascript.candidate", params: params)
    }
    
    func mediaSessionDidClose(_ mediaSession: UserMediaSession) {
        os_log("Releasing media session", type: .debug)
        self.mediaSessions[mediaSession.id] = nil
    }
}
