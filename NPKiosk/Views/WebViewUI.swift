//
//  WebViewUI.swift
//  NPKiosk
//
//  Created by Tyler Schrock on 7/7/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit

struct WebViewUI: View {
    
    let webview: WKWebView
    let initialUrl: String
    @State private var progress: CGFloat = 0
    @State private var showProgress: Bool = false
    @State private var showHttpError: Bool = false
    @State private var httpErrorCode: String = ""
    @State private var httpErrorMessasge: String = ""
    
    init(webview: WKWebView, initialUrl: String) {
        self.webview = webview
        self.initialUrl = initialUrl
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            WKWebViewWrapper(
                webview: self.webview,
                onProgress: { show, progress in
                    if let show = show { self.showProgress = show }
                    self.progress = progress
            },
                onError: { show, title, message in
                    if let show = show { self.showHttpError = show }
                    self.httpErrorCode = title
                    self.httpErrorMessasge = message
            }
            ).onAppear {
                self.resetWebView()
            }
            if(showHttpError) {
                ErrorView(onRetryClick: self.reloadWebView, onResetClick: self.resetWebView) {
                    Text(self.httpErrorCode)
                        .font(.largeTitle)
                        .bsPadding(vertical: 10.0, horizontal: 15.0)
                    Text(self.httpErrorMessasge)
                        .bsPadding(vertical: 10.0, horizontal: 15.0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            if(showProgress) {
                ProgressBar(height: 10, value: self.$progress)
            }
        }
    }
    
    func reloadWebView() {
        self.webview.reloadFromOrigin()
    }
    
    func resetWebView() {
        if let url = URL(string: self.initialUrl) {
            self.webview.load(URLRequest(url: url))
            self.showProgress = true
            self.progress = 0.1
        }
    }
    
    struct WKWebViewWrapper: UIViewRepresentable {
        
        let webview: WKWebView
        var onProgress: (_ show: Bool?, _ progress: CGFloat) -> Void
        var onError: (_ show: Bool?, _ title: String, _ message: String) -> Void
        
        func makeUIView(context: Context) -> WKWebView  {
            return webview
        }
        
        func updateUIView(_ webView: WKWebView, context: Context) {
            //
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(webview: webview, onProgress: onProgress, onError: onError)
        }
        
        class Coordinator: NSObject, WKNavigationDelegate {
            var onProgress: (_ show: Bool?, _ progress: CGFloat) -> Void
            var onError: (_ show: Bool?, _ title: String, _ message: String) -> Void
            
            init(
                webview: WKWebView,
                onProgress: @escaping (_ show: Bool?, _ progress: CGFloat) -> Void,
                onError: @escaping (_ show: Bool?, _ title: String, _ message: String) -> Void
            ) {
                self.onProgress = onProgress
                self.onError = onError
                super.init()
                webview.navigationDelegate = self
                webview.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
            }
            
            func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
                self.onProgress(true, 0.1)
                self.onError(false, "", "")
            }
            
            func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                self.onProgress(false, 0)
                self.onError(false, "", "")
            }
            
            func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
                self.onProgress(false, 0)
                self.onError(true, "Error: \((error as NSError).code)", error.localizedDescription)
            }
            
            func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
                self.onProgress(false, 0)
                self.onError(true, "Error: \((error as NSError).code)", error.localizedDescription)
            }
            
            override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
                if keyPath == "estimatedProgress" && object != nil {
                    let progress = CGFloat((object as! WKWebView).estimatedProgress)
                    DispatchQueue.main.async {
                        self.onProgress(nil, progress)
                    }
                }
            }
        }
    }
    
}

struct WebViewUI_Previews: PreviewProvider {
    static var previews: some View {
        WebViewUI(webview: WKWebView(), initialUrl: "https://example.com")
            .statusBar(hidden: true)
            .edgesIgnoringSafeArea(.all)
    }
}
