//
//  CameraService.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 6/29/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation

class CameraService: ObservableObject {
    @Published var showScanner = false
    func start(passive: Bool) {
        self.showScanner = passive
    }
    
    func stop() {
        self.showScanner = false
    }
    
    func setKioskId(kioskId: Int) {
        
    }
}
