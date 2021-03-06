//
//  AppDelegate.swift
//  NPKiosk
//
//  Created by Tyler Schrock on 4/27/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let settingsService: SettingsService
    let webRTCService: WebRTCService
    let labelPrintService: LabelPrintService
    let labelCacheService: LabelCacheService
    let cameraService: CameraService
    
    override init() {
        self.settingsService = SettingsService()
        self.webRTCService = WebRTCService()
        self.labelCacheService = LabelCacheService(self.settingsService)
        self.labelPrintService = LabelPrintService(self.settingsService, self.labelCacheService)
        self.cameraService = CameraService()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

