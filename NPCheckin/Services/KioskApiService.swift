//
//  ClientApiService.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 6/22/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation
import Promises

class KioskApiService: ObservableObject {
    
    private let screenService: ScreenService
    private let settingsService: SettingsService
    private let labelPrintService: LabelPrintService
    private let cameraService: CameraService
    private var toggleCodeScanner: ((_ enabled: Bool) -> Void)?
    
    init(
        _ screenService: ScreenService,
        _ settingsService: SettingsService,
        _ labelPrintService: LabelPrintService,
        _ cameraService: CameraService
    ) {
        self.screenService = screenService
        self.settingsService = settingsService
        self.labelPrintService = labelPrintService
        self.cameraService = cameraService
    }
    
    func PrintLabels(labels: Array<CheckinLabel>) -> Promise<Void> {
        return self.labelPrintService.print(labels: labels).then { _ in }
    }
    
    func StartCamera(passive: Bool) {
        self.cameraService.start(passive: passive)
    }
    
    func StopCamera() {
        self.cameraService.stop()
    }
    
    func SetKioskId(kioskId: Int) {
        self.cameraService.setKioskId(kioskId: kioskId)
    }
    
    func PrintCards(cards: Array<ZebraCard>) {
        // Not Supported
    }
    
    func GetAppPreference(key: String) -> String? {
        self.settingsService.getString(forKey: key)
    }
    
    func SetAppPreference(key: String, value: String?) {
        self.settingsService.setString(forKey: key, value: value)
    }
    
    func ShowSettings() {
        self.screenService.current = .inAppSettings
    }
}
