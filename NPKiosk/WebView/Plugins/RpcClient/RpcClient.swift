//
//  RpcClient.swift
//  NPKiosk
//
//  Created by Tyler Schrock on 5/12/20.
//  Copyright © 2020 NewPointe Community Church. All rights reserved.
//

import Foundation
import WebKit
import Promises

typealias RpcMethod0<Result: Encodable> = () throws -> Promise<Result>?
typealias RpcMethod1<T1: Decodable, Result: Encodable> = (_ param1: T1) throws -> Promise<Result>?
typealias RpcMethod2<T1: Decodable, T2: Decodable, Result: Encodable> = (_ param1: T1, _ param2: T2) throws -> Promise<Result>?


class RpcClient: NSObject, WKScriptMessageHandler {
    
    private var handlerGenerators = RpcRequestHandlerGeneratorCollection()
    
    func registerMethod<Result: Encodable>(_ name: String, _ method: @escaping RpcMethod0<Result>) {
        handlerGenerators[name] = { decoder in
            {
                try method()?.then { result in result }
            }
        }
    }
    
    func registerMethod<T1: Decodable, Result: Encodable>(_ name: String, _ method: @escaping RpcMethod1<T1, Result>) {
        handlerGenerators[name] = { decoder in
            let container = try decoder.container(keyedBy: RpcIncomingRequest.CodingKeys.self)
            var paramsContainer = try container.nestedUnkeyedContainer(forKey: .params)
            let param1 = try paramsContainer.decode(T1.self)
            return {
                try method(param1)?.then { result in result }
            }
        }
    }
    
    func registerMethod<T1: Decodable, T2: Decodable, Result: Encodable>(_ name: String, _ method: @escaping RpcMethod2<T1, T2, Result>) {
        handlerGenerators[name] = { decoder in
            let container = try decoder.container(keyedBy: RpcIncomingRequest.CodingKeys.self)
            var paramsContainer = try container.nestedUnkeyedContainer(forKey: .params)
            let param1 = try paramsContainer.decode(T1.self)
            let param2 = try paramsContainer.decode(T2.self)
            return {
                try method(param1, param2)?.then { result in result }
            }
        }
    }
    
    private weak var webView: WKWebView?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private var callbacks = Dictionary<String, Promise<JsonValue>>()
    
    required init(webView: WKWebView) {
        self.webView = webView
        super.init()
        let source = """
        (() => {
            window.addEventListener('message', event => {
                if(event.origin === window.origin && event.data && event.data.jsonrpc === "2.0") {
                    window.webkit.messageHandlers.RpcClient.postMessage(event.data);
                }
            }, false);
        })();
        """
        let script = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(script)
        webView.configuration.userContentController.add(self, name: "RpcClient")
    }
    
    /// Sends an RPC request to the WKWebView.
    /// - Parameters:
    ///   - method: The method to run.
    ///   - params: The parameters for the method.
    /// - Throws: There was an error encoding the message.
    /// - Returns: A Promise that will be resolved with the result of running the method.
    func sendRequest<T>(method: String, params: RpcParameters<T>) throws -> Promise<JsonValue> where T : Codable {
        let id = UUID().uuidString
        let promise = Promise<JsonValue>.pending()
        self.callbacks[id] = promise
        try self.postMessage(RpcRequest(id: .string(id), method: method, params: params))
        return promise
    }
    
    /// Sends an RPC notification to the WKWebView
    /// - Parameters:
    ///   - method: The method to run.
    ///   - params: The parameters for the method.
    /// - Throws: There was an error encoding the notification.
    func sendNotification<T>(method: String, params: RpcParameters<T>) throws where T : Encodable {
        try self.postMessage(RpcRequest(id: nil, method: method, params: params))
    }
    
    private func sendResult<T>(id: RpcIdentifier, result: T) throws where T : Encodable {
        try self.postMessage(RpcResponseWithResult(id: id, result: result))
    }
    
    private func sendError<T>(id: RpcIdentifier, error: T) throws where T : AnyRpcError, T : Encodable {
        try self.postMessage(RpcResponseWithError(id: id, error: error))
    }
    
    /// Posts a message to the assiciated WKWebView.
    /// - Parameter message: The message to send to the WKWebView.
    /// - Throws: There was an error encoding the message.
    private func postMessage<T>(_ message: T) throws where T : Encodable {
        let messageData = try self.encoder.encode(message)
        if let messageString = String(data: messageData, encoding: .utf8) {
            if Thread.isMainThread {
                self.webView?.evaluateJavaScript("window.postMessage(\(messageString), window.origin)")
            }
            else {
                DispatchQueue.main.async {
                    self.webView?.evaluateJavaScript("window.postMessage(\(messageString), window.origin)")
                }
            }
        }
        else {
            throw RpcClientError.encodingFailed
        }
    }
    
    internal func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let dataString = message.body as? String {
            self.decoder.userInfo[RpcIncomingRequest.handlerGeneratorsKey] = self.handlerGenerators
            if let decoded = try? self.decoder.decode(RpcIncomingMessage.self, from: Data(dataString.utf8)) {
                switch decoded {
                case let .request(request):
                    do {
                        if let result = try request.handle() {
                            result.then { result in
                                if(request.id != nil) {
                                    try self.sendResult(id: request.id!, result: AnyEncodable(value: result))
                                }
                            }
                            .catch { error in
                                if(request.id != nil) {
                                    try? self.sendError(id: request.id!, error: error as? RpcError ?? RpcError(code: -32603, message: "Internal error"))
                                }
                            }
                        }
                    }
                    catch {
                        if(request.id != nil) {
                            try? self.sendError(id: request.id!, error: error as? RpcError ?? RpcError(code: -32603, message: "Internal error"))
                        }
                    }
                case let .result(result):
                    if case let .string(id) = result.id {
                        if let promise = self.callbacks[id] {
                            promise.fulfill(result.result)
                        }
                    }
                case let .error(error):
                    if case let .string(id) = error.id {
                        if let promise = self.callbacks[id] {
                            promise.reject(error.error)
                        }
                    }
                }
            }
        }
    }
    
    enum RpcClientError: Error {
        case encodingFailed
    }
}

