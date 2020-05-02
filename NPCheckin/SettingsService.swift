//
//  SettingsService.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 4/30/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation

struct SettingsService {

    private enum Keys {
        static let kioskAddress = "kiosk-address"
    }

    static var kioskAddress: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.kioskAddress) ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.kioskAddress)
        }
    }
}
