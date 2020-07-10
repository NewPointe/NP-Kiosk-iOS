//
//  SettingsService.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 4/30/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation
import AVFoundation

class SettingsService: ObservableObject {
    
    private enum Keys {
        static let kioskAddress = "kiosk_address"
        static let inAppSettings = "in_app_settings"
        static let inAppSettingsDelay = "in_app_settings_delay"
        static let enableCaching = "enable_caching"
        static let cacheDuration = "cache_duration"
        static let printerOverride = "printer_override"
        static let cameraPosition = "camera_position"
        static let printerTimeout = "printer_timeout"
    }
    
    func getString(forKey: String) -> String? {
        UserDefaults.standard.string(forKey: forKey)
    }
    
    func setString(forKey: String, value: String?) {
        UserDefaults.standard.setValue(value, forKey: forKey)
    }
    
    var kioskAddress: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.kioskAddress)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.kioskAddress)
        }
    }
    
    var inAppSettingsDelay: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.inAppSettingsDelay)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.inAppSettingsDelay)
        }
    }
    
    var enableCaching: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.enableCaching)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.enableCaching)
        }
    }
    
    var cacheDuration: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.cacheDuration)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.cacheDuration)
        }
    }
    
    var printerOverride: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.printerOverride)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.printerOverride)
        }
    }
    
    var cameraPosition: AVCaptureDevice.Position {
        get {
            return AVCaptureDevice.Position(value: UserDefaults.standard.string(forKey: Keys.cameraPosition)) ?? .unspecified
        }
        set {
            UserDefaults.standard.setValue(newValue.description, forKey: Keys.cameraPosition)
        }
    }
    
    var printerTimeout: Int {
        get {
            return UserDefaults.standard.integer(forKey: Keys.printerTimeout)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.printerTimeout)
        }
    }
}

