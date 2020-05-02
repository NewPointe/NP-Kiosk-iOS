//
//  WebView.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 4/27/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import SwiftUI
import WebKit

struct KioskWebView: View {
    @Binding var currentViewState: AppScreen
    @State private var progress: CGFloat = 0
    @State private var showProgress: Bool = false
    @State private var showScanner: Bool = false
    private var coordinator: Coordinator
    
    init() {
        self.coordinator = Coordinator(self)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            FullscreenWebView { webView in
                
                    // Basic config
                    webView.allowsBackForwardNavigationGestures = false
                    webView.allowsLinkPreview = false
                
                    // Register out coordinator for events and updates
                    webView.navigationDelegate = self.coordinator
                    webView.addObserver(self.coordinator, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
                    
                    // Load the URL
                    let urlString = SettingsService.kioskAddress
                    if let url = URL(string: urlString) {
                        let request = URLRequest(url: url)
                        webView.load(request)
                    }
                    else {
                        self.currentViewState = AppScreen.urlentryview
                    }
            }
            Group {
                if(showProgress) {
                    ProgressBar(
                        barColor: UIColor(red: 1, green: 0.5, blue: 0, alpha: 0.6),
                        height: 5,
                        value: self.$progress
                    )
                }
                if(showScanner) {
                    CodeScannerView(codeTypes: [.qr], completion: self.onQrScan)
                }
            }
        }
    }
    
    func onQrScan(result: Result<String, CodeScannerView.ScanError>) {
        
    }
    
    func onLoadStatusChanged(isLoading: Bool, error: Error?) {
    }
    
    func onProgressChanged(progress: Double) {
        DispatchQueue.main.async {
            self.progress = CGFloat(progress)
        }
    }


    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: KioskWebView
        
        init(_ parent: KioskWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            self.parent.showProgress = true
            self.parent.progress = 0.1
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.parent.showProgress = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            self.parent.showProgress = false
        }

        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "estimatedProgress" && object != nil {
                let progress = CGFloat((object as! WKWebView).estimatedProgress)
                self.parent.progress = progress
            }
        }
    }
}

struct KioskWebView_Previews: PreviewProvider {
    @State static var currentViewState: AppScreen = .webview
    static var previews: some View {
        KioskWebView(currentViewState: self.$currentViewState, progress: 0.5, showProgress: true)
    }
}
