//
//  LabelCacheService.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 6/22/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation
import Promises

class LabelCacheService: ObservableObject {
    private let settingsService: SettingsService
    private let queue = DispatchQueue(label: "org.newpointe.kiosk.labelcachequeue", attributes: .concurrent)
    private var labels = Dictionary<URL, CachedLabelData>()
    
    init(_ settingsService: SettingsService) {
        self.settingsService = settingsService
    }
    
    func getCachedLabel(labelUrl: URL) -> CachedLabelData? {
        var cachedLabel: CachedLabelData?
        self.queue.sync {
            cachedLabel = self.labels[labelUrl]
        }
        if let label = cachedLabel, label.getAge() < self.settingsService.cacheDuration {
            return label
        }
        else {
            return nil
        }
    }
    
    func getRemoteLabel(labelUrl: URL) -> Promise<CachedLabelData> {
        return Promise { resolve, reject in
            URLSession.shared.dataTask(with: labelUrl) { (data, response, error) in
                if let error = error {
                    reject(error)
                }
                else if let data = data {
                    resolve(CachedLabelData(url: labelUrl, content: String(data: data, encoding: .utf8)!))
                }
            }.resume()
        }
    }
    
    func getLabel(labelUrl: URL) -> Promise<CachedLabelData> {
        if self.settingsService.enableCaching {
            if let cachedLabel = self.getCachedLabel(labelUrl: labelUrl) {
                return Promise(cachedLabel)
            }
            else {
                return self.getRemoteLabel(labelUrl: labelUrl).then { label in
                    self.queue.sync(flags: .barrier) {
                        self.labels[labelUrl] = label
                    }
                }
            }
        }
        else {
            return self.getRemoteLabel(labelUrl: labelUrl)
        }
    }
}
