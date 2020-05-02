//
//  InternalWebView.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 4/29/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import SwiftUI
import WebKit

struct FullscreenWebView: UIViewRepresentable {
    var configure: (FullScreenWKWebView) -> Void
    
    func makeUIView(context: Context) -> FullScreenWKWebView  {
        let webView = FullScreenWKWebView()
        self.configure(webView)
        return webView
//        webView.allowsBackForwardNavigationGestures = false
//        webView.allowsLinkPreview = false
//        webView.navigationDelegate = context.coordinator
//        webView.addObserver(context.coordinator, forKeyPath: #keyPath(FullScreenWKWebView.estimatedProgress), options: .new, context: nil)
//        let urlString = SettingsService.kioskAddress
//        if let url = URL(string: urlString) {
//            let request = URLRequest(url: url)
//            webView.load(request)
//        }
//        else {
//            currentViewState = AppScreen.urlentryview
//        }
    }

    func updateUIView(_ webView: FullScreenWKWebView, context: Context) {
        //
    }
    
    class FullScreenWKWebView: WKWebView {
        override var safeAreaInsets: UIEdgeInsets {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}
