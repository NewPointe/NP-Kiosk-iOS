//
//  KioskWebView.swift
//  NPKiosk
//
//  Created by Tyler Schrock on 6/23/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation

import SwiftUI
import WebKit

class KioskWKWebView: WKWebView {
    
    private var rpcClient: RpcClient!
    private var getUserMediaShim: GetUserMediaShim!
    private var kioskApi: KioskApi!
    private var webRTCService: WebRTCService!
    private var kioskApiService: KioskApiService!
    
    init(webRTCService: WebRTCService, kioskApiService: KioskApiService) {
        self.webRTCService = webRTCService
        self.kioskApiService = kioskApiService
        
        let webConfiguration = WKWebViewConfiguration()
        
        webConfiguration.applicationNameForUserAgent = Bundle.main.displayName
        // Enable Safari remote debugging
        webConfiguration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        webConfiguration.ignoresViewportScaleLimits = false
        webConfiguration.suppressesIncrementalRendering = false
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.allowsAirPlayForMediaPlayback = false
        webConfiguration.allowsPictureInPictureMediaPlayback = false
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        webConfiguration.selectionGranularity = .character
        webConfiguration.dataDetectorTypes = []
        webConfiguration.defaultWebpagePreferences.preferredContentMode = .desktop
        
        super.init(frame: .zero, configuration: webConfiguration)
        
        self.rpcClient = RpcClient(webView: self)
        self.getUserMediaShim = GetUserMediaShim(webView: self, rpcClient: self.rpcClient, webRTCService: self.webRTCService)
        self.kioskApi = KioskApi(webView: self, rpcClient: self.rpcClient, kioskApiService: self.kioskApiService)
        
        self.allowsBackForwardNavigationGestures = false
        self.allowsLinkPreview = false
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
