//
//  CachedLabelData.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 6/22/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation

struct CachedLabelData {
    let url: URL
    let content: String
    private let createdMilliseconds = ProcessInfo.processInfo.systemUptime
    
    func getAge() -> Int {
        return Int(ProcessInfo.processInfo.systemUptime - self.createdMilliseconds)
    }
    
    func getMerged(fields: Dictionary<String, String>?) -> String {
        if fields == nil { return self.content }
        var mergedContent = self.content
        for (key, value) in fields! {
            if !value.isEmpty {
                mergedContent = mergedContent.replacingOccurrences(of: "(?<=\\^FD)(\(key))(?=\\^FS)", with: value, options: .regularExpression)
            }
            else {
                mergedContent = mergedContent.replacingOccurrences(of: "\\^FO.*\\^FS\\s*(?=\\^FT.*\\^FD\(key)\\^FS)", with: "", options: .regularExpression)
                mergedContent = mergedContent.replacingOccurrences(of: "\\^FD\(key)\\^FS", with: "", options: .regularExpression)
            }
        }
        return mergedContent
    }
}
