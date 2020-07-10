//
//  ContentView.swift
//  NPKiosk
//
//  Created by Tyler Schrock on 4/27/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import SwiftUI
import Combine


struct ContentView: View {
    @EnvironmentObject var screenService: ScreenService
    
    var body: some View {
        return Group {
            if self.screenService.current == Screen.kiosk {
                KioskScreen()
            }
            else if self.screenService.current == Screen.inAppSettings {
                FirstTimeSetupScreen()
            }
            else {
                FirstTimeSetupScreen()
            }
        }
        .statusBar(hidden: true)
        .edgesIgnoringSafeArea(.all)
    }
}
