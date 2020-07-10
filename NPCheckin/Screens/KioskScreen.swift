//
//  WebView.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 4/27/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import SwiftUI
import WebKit

struct KioskScreen: View {
    
    @EnvironmentObject private var screenService: ScreenService
    @EnvironmentObject private var settingsService: SettingsService
    @EnvironmentObject private var webRTCService: WebRTCService
    @EnvironmentObject private var kioskApiService: KioskApiService
    @State private var showScanner: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            WebViewUI(
                webview: KioskWKWebView(webRTCService: webRTCService, kioskApiService: kioskApiService),
                initialUrl: settingsService.kioskAddress ?? ""
            )
            Group {
                if(showScanner) {
                    CodeScannerView(codeTypes: [.qr], completion: self.onQrScan)
                }
            }
        }
    }
    
    func onQrScan(result: Result<String, CodeScannerView.ScanError>) {
        
    }

}
