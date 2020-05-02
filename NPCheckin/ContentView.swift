//
//  ContentView.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 4/27/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import SwiftUI
import Combine

enum AppScreen {
    case webview
    case urlentryview
    case codescanner
}

struct ContentView: View {
    
    @State private var currentViewState: AppScreen = URL(string: UserDefaults.standard.string(forKey: "checkin_address") ?? "") != nil ? AppScreen.webview : AppScreen.urlentryview
    
    var body: some View {
        return Group {
            if currentViewState == AppScreen.webview {
                WebView(currentViewState: self.$currentViewState)
            }
            else {
                UrlEntryView(currentAppScreen: self.$currentViewState)
            }
        }
        .statusBar(hidden: true)
        .edgesIgnoringSafeArea(.all)
    }
}
