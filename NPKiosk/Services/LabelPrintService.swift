//
//  LabelPrintService.swift
//  NPKiosk
//
//  Created by Tyler Schrock on 6/22/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation
import Promises
import SwiftSocket

enum PrintError: Error {
    case invalidPrinter(String), printerTimeout(String), printerError(String)
}

class LabelPrintService: ObservableObject {
    
    private let settingsService: SettingsService
    private let labelCacheService: LabelCacheService

    init(
        _ settingsService: SettingsService,
        _ labelCacheService: LabelCacheService
    ) {
        self.settingsService = settingsService
        self.labelCacheService = labelCacheService
    }
    
    /// Gets the URL representing the printer's location
    /// - Parameter address: The address of the printer
    /// - Returns: A URL representing the printer's location
    private func normalizePrinterAddress(address: String) -> URL? {
        let parts = address.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
        if(parts.count == 2) {
            switch parts[0] {
                case "bluetooth":
                    let host = parts[1].trimWhitespace(and: "[]/")
                    return URL(string: "bluetooth:\(host)")
                case "usb":
                    let host = parts[1].trimWhitespace(and: "[]/")
                    return URL(string: "usb:\(host)")
                case "tcp":
                    let host = parts[1].trimWhitespace(and: "/")
                    return URL(string: "tcp://\(host)")
                default:
                    let host = address.trimWhitespace(and: "/")
                    return URL(string: "tcp://\(host)")
            }
        }
        else if(parts.count == 1) {
            let host = address.trimWhitespace(and: "/")
            return URL(string: "tcp://\(host)")
        }
        else {
            return nil
        }
    }
    
    func print(labels: Array<CheckinLabel>) -> Promise<Array<Error>> {
        let printerOverride = self.settingsService.printerOverride
        var jobs = Array<PrintJob>()
        var errors = Array<Error>()
        var seenLabels = Dictionary<URL, CachedLabelData>()
        return labels.forEachAsync { label in

            guard let printerAddress = printerOverride ?? label.PrinterAddress, !printerAddress.isEmpty else {
                errors.append(PrintError.invalidPrinter("Could not print label: Invalid printer: Printer Address is null"))
                return Promise(())
            }
            
            guard let printerUri = self.normalizePrinterAddress(address: printerAddress) else {
                errors.append(PrintError.invalidPrinter("Could not print label: Invalid printer address"))
                return Promise(())
            }

            guard let labelUrl = URL(string: label.LabelFile) else {
                errors.append(PrintError.invalidPrinter("Could not print label: Invalid label URL"))
                return Promise(())
            }
            
            if let seenLabel = seenLabels[labelUrl] {
                let printData = seenLabel.getMerged(fields: label.MergeFields)
                jobs.append(PrintJob(printerUri: printerUri, data: printData))
                return Promise(())
            }
            else {
                return self.labelCacheService.getLabel(labelUrl: labelUrl).then { labelData in
                    seenLabels[labelUrl] = labelData
                    let printData = labelData.getMerged(fields: label.MergeFields)
                    jobs.append(PrintJob(printerUri: printerUri, data: printData))
                    return Promise(())
                }
            }
            
        }
        .then {
            return self.print(jobs: jobs, parseErrors: errors)
        }
    }
    
    func print(jobs: Array<PrintJob>, parseErrors: Array<Error>) -> Promise<Array<Error>> {
        var errors = Array<Error>()
        errors.append(contentsOf: parseErrors)
        return Dictionary(grouping: jobs, by: { $0.printerUri }).forEachAsync { (url, jobs) in
            return self.print(connection: url, data: jobs.map { $0.data }).recover { error in
                errors.append(error)
            }
        }.then {
            return errors
        }
    }
    
    func print(connection: URL, data: Array<String>) -> Promise<Void> {
        return Promise { resolve, reject in
            DispatchQueue.global(qos: .userInitiated).async {
                switch connection.scheme {
                    case "tcp":
                        if let host = connection.host {
                            let port = Int32(connection.port ?? 9100)
                            let client = TCPClient(address: host, port: port)
                            switch client.connect(timeout: self.settingsService.printerTimeout) {
                                case .success:
                                    for string in data {
                                        switch client.send(string: string) {
                                            case .success:
                                                continue
                                            case .failure(let error):
                                                reject(error)
                                                return
                                        }
                                    }
                                    client.close()
                                case .failure(let error):
                                    reject(error)
                            }
                        }
                        else {
                            reject(PrintError.invalidPrinter("Can not print to printer '\(connection)': Invalid host."))
                        }
                    default:
                        reject(PrintError.invalidPrinter("Can not print to printer '\(connection)': Connection type '\(connection.scheme ?? "<null>")' is not supported."))
                }
            }
        }
    }
    
}

extension Sequence {
    func mapAsync<U>(_ body: @escaping (_ value: Element) throws -> Promise<U>) -> Promise<Array<U>> {
        let promise = Promise<Array<U>>.pending()
        var iterator = self.makeIterator()
        var results = Array<U>()
        var next: (() -> Void)?
        
        next = {
            if let value = iterator.next() {
                do {
                    try body(value).then { result in
                        results.append(result)
                        next!()
                    }.catch { error in
                        promise.reject(error)
                    }
                }
                catch let error {
                    promise.reject(error)
                }
            }
            else {
                promise.fulfill(results)
            }
        }
        
        DispatchQueue.global().async(execute: next!)
        return promise
    }
    
    func forEachAsync(_ body: @escaping (_ value: Element) throws -> Promise<Void>) -> Promise<Void> {
        let promise = Promise<Void>.pending()
        var iterator = self.makeIterator()
        var next: (() -> Void)?
        
        next = {
            if let value = iterator.next() {
                do {
                    try body(value).then(next!).catch { error in
                        promise.reject(error)
                    }
                } catch let error {
                    promise.reject(error)
                }
            }
            else {
                promise.fulfill(())
            }
        }
        
        DispatchQueue.global().async(execute: next!)
        return promise
    }
}
