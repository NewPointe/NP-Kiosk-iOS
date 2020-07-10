//
//  AppScreenService.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 6/22/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation

enum Screen {
    case kiosk
    case firstTimeSetup
    case inAppSettings
}

class ScreenService: ObservableObject {
    @Published var current = Screen.kiosk
}
