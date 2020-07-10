//
//  CheckinLabel.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 6/22/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation

struct CheckinLabel: Decodable, Encodable {
    let LabelFile: String
    let MergeFields: Dictionary<String, String>
    let PrinterAddress: String?
}
