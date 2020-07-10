//
//  WebRTCPeerConnection.swift
//  NPKiosk
//
//  Created by Tyler Schrock on 6/22/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import AVFoundation
import Foundation
import os.log
import Promises
import WebRTC

protocol UserMediaSessionDelegate: class {
    func mediaSessionDidClose(_ mediaSession: UserMediaSession)
    func mediaSession(_ mediaSession: UserMediaSession, didGenerate candidate: RTCIceCandidate)
}

struct AVCaptureDeviceConfiguration: Hashable {
    let device: AVCaptureDevice
    let format: AVCaptureDevice.Format
}

class UserMediaSession: NSObject, RTCPeerConnectionDelegate {

    public let id: String
    private weak var webRTCService: WebRTCService?
    private var peerConnection: RTCPeerConnection?
    private var videoSource: RTCVideoSource?
    private var videoCapturer: RTCCameraVideoCapturer?
    private var localVideoTrack: RTCVideoTrack?
    weak var delegate: UserMediaSessionDelegate?
    private var closed: Bool = false
    
    init(id: String, webRTCService: WebRTCService, delegate: UserMediaSessionDelegate) {
        os_log("Creating a media session with ID %{public}s", type: .debug, id)
        self.id = id
        self.webRTCService = webRTCService
        self.delegate = delegate
        
        self.peerConnection = webRTCService.peerConnection(
            with: {
                let config = RTCConfiguration()
                config.iceServers = []
                config.sdpSemantics = .unifiedPlan
                config.continualGatheringPolicy = .gatherContinually
                return config
            }(),
            constraints: RTCMediaConstraints(
                mandatoryConstraints: nil,
                optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue]
            ),
            delegate: nil
        )
        
        self.videoSource = webRTCService.videoSource()
        self.videoCapturer = RTCCameraVideoCapturer(delegate: self.videoSource!)
        self.localVideoTrack = webRTCService.videoTrack(with: self.videoSource!, trackId: "video0")
        
        super.init()
        
        queue {
            self.peerConnection!.add(self.localVideoTrack!, streamIds: ["stream"])
        }
        self.peerConnection!.delegate = self
    }
    
    func queue(execute block: @escaping () -> Void) {
        self.webRTCService!.queue.async(execute: block)
    }
    
    func createOffer() -> Promise<RTCSessionDescription> {
        os_log("%{public}@: Creating an offer", type: .debug, self.id)
        return Promise { resolve, reject in
            self.queue {
                self.peerConnection!.offer(
                    for: RTCMediaConstraints(
                        mandatoryConstraints: nil,
                        optionalConstraints: nil
                    )
                ) { sdp, error in
                    if let error = error {
                        reject(error)
                    }
                    else if let sdp = sdp {
                        resolve(sdp)
                    }
                }
            }
        }
    }
    
    func createAnswer() -> Promise<RTCSessionDescription> {
        os_log("%{public}@: Creating an answer", type: .debug, self.id)
        return Promise { resolve, reject in
            self.queue {
                self.peerConnection!.answer(
                    for: RTCMediaConstraints(
                        mandatoryConstraints: nil,
                        optionalConstraints: nil
                    )
                ) { sdp, error in
                    if let error = error {
                        reject(error)
                    }
                    else if let sdp = sdp {
                        resolve(sdp)
                    }
                }
            }
        }
    }
    
    func setLocalDescription(localSdp: RTCSessionDescription) -> Promise<Void> {
        os_log("%{public}@: Setting local description", type: .debug, self.id)
        return Promise { resolve, reject in
            self.queue {
                self.peerConnection!.setLocalDescription(localSdp) { error in
                    if let error = error {
                        reject(error)
                    }
                    else {
                        resolve(())
                    }
                }
            }
        }
    }
    
    func setRemoteDescription(remoteSdp: RTCSessionDescription) -> Promise<Void> {
        os_log("%{public}@: Setting remote description", type: .debug, self.id)
        return Promise { resolve, reject in
            self.queue {
                self.peerConnection!.setRemoteDescription(remoteSdp) { error in
                    if let error = error {
                        reject(error)
                    }
                    else {
                        resolve(())
                    }
                }
            }
        }
    }
    
    func add(candidate: RTCIceCandidate) {
        os_log("%{public}@: Adding candidate", type: .debug, self.id)
        self.queue {
            self.peerConnection?.add(candidate)
        }
    }
    
    private func getBestCameraAndFormat() -> AVCaptureDeviceConfiguration? {
        var fitnessMap = Dictionary<AVCaptureDeviceConfiguration, Double>()
        for camera in RTCCameraVideoCapturer.captureDevices() {
            var fitness = 0.0;
            switch camera.position {
            case .front:
                fitness += 300
            case .unspecified:
                fitness += 200
            case .back:
                fitness += 100
            default:
                fitness += 000
            }
            for format in RTCCameraVideoCapturer.supportedFormats(for: camera) {
                let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
                if(dimensions.width < 1200 && dimensions.height < 800) {
                    fitness += Double(dimensions.width) / 130.0;
                    fitness += Double(dimensions.height) / 80.0;
                    var aspectRatio = Double(dimensions.width) / Double(dimensions.height)
                    if aspectRatio > 1.0 {
                        aspectRatio = 1 / aspectRatio
                    }
                    fitness += (1 - aspectRatio) * 20
                    for range in format.videoSupportedFrameRateRanges {
                        if range.minFrameRate < 10 && range.maxFrameRate > 10 {
                            fitnessMap[AVCaptureDeviceConfiguration(device: camera, format: format)] = fitness
                        }
                    }
                }
            }
        }
        return fitnessMap.sorted{ $0.1 > $1.1 }.first?.key
    }
    
    func close() {
        os_log("%{public}@: Cleaning up everything", type: .debug, self.id)
        self.queue {
            if !self.closed {
                self.closed = true
                self.videoCapturer?.stopCapture()
                self.peerConnection?.close()
                self.webRTCService = nil
                self.videoSource = nil
                self.videoCapturer = nil
                self.localVideoTrack = nil
                self.peerConnection?.delegate = nil
                self.peerConnection = nil
                self.delegate = nil
            }
        }
    }
    
    func startVideoCapture() {
        self.queue {
            if let bestDeviceConfig = self.getBestCameraAndFormat()
            {
                let name = bestDeviceConfig.device.localizedName
                let dimensions = bestDeviceConfig.format.formatDescription.dimensions
                os_log("%{public}s: Starting video capture using device %{public}s with format %{public}dx%{public}d.", type: .debug, self.id, name, dimensions.width, dimensions.height)
                
                self.videoCapturer?.startCapture(with: bestDeviceConfig.device, format: bestDeviceConfig.format, fps: 10)
            }
        }
    }
    
    internal func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        os_log("%{public}@: PeerConnection should negotiate", type: .debug, self.id)
    }
    
    internal func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        os_log("%{public}@: PeerConnection signaling state changed to %{public}@", type: .debug, self.id, stateChanged.description)
    }
    
    internal func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        os_log("%{public}@: PeerConnection added media stream %{public}@", type: .debug, self.id, stream.streamId)
    }
    
    internal func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        os_log("%{public}@: PeerConnection removed media stream %{public}@", type: .debug, self.id, stream.streamId)
    }
    
    internal func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        os_log("%{public}@: PeerConnection ICE connection state changed to %{public}@", type: .debug, self.id, newState.description)
        switch newState {
            case .connected:
                self.startVideoCapture()
            case .disconnected, .failed:
                self.close()
            case .closed:
                self.delegate?.mediaSessionDidClose(self)
            default: return
        }
    }
    
    internal func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        os_log("%{public}@: PeerConnection ICE gathering state changed to %{public}@", type: .debug, self.id, newState.description)
    }
    
    internal func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        os_log("%{public}@: PeerConnection generated candidate %{public}@", type: .debug, self.id, candidate.sdp)
        self.delegate?.mediaSession(self, didGenerate: candidate)
    }
    
    internal func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        os_log("%{public}@: PeerConnection removed %{public}@ candidates", type: .debug, self.id, candidates.count)
    }
    
    internal func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        os_log("%{public}@: PeerConnection opened data channel %{public}@", type: .debug, self.id, dataChannel)
    }
}
