//
//  KioskApi.swift
//  NPCheckin
//
//  Created by Tyler Schrock on 5/21/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation
import WebKit

class KioskApi {
    
    private weak var rpcClient: RpcClient?
    private weak var kioskApiService: KioskApiService?
    
    required init(webView: WKWebView, rpcClient: RpcClient, kioskApiService: KioskApiService) {
        self.rpcClient = rpcClient
        self.kioskApiService = kioskApiService
    }
}
