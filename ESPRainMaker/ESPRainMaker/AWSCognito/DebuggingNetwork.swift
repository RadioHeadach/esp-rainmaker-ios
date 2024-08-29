//
//  DebuggingNetwork.swift
//  ESPRainMaker
//
//  Created by Bowjob David on 2024/8/29.
//  Copyright © 2024 Espressif. All rights reserved.
//

import Alamofire
import Foundation

class LoggingEventMonitor: EventMonitor {
    func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest) {
        let caller = getCallerInfo()
        print("--------------------🚀 Request created by: \(caller)--------------------")
        print("URL: \(urlRequest.url?.absoluteString ?? "Unknown URL")")
        print("Method: \(urlRequest.httpMethod ?? "Unknown method")")
        print("Headers: \(urlRequest.allHTTPHeaderFields ?? [:])")
        if let httpBody = urlRequest.httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
    }

    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        print("--------------------📡 Response for \(response.request?.url?.absoluteString ?? "Unknown URL"):--------------------")
        print("Status Code: \(response.response?.statusCode ?? 0)")
        if let headers = response.response?.allHeaderFields {
            print("Headers: \(headers)")
        }
        switch response.result {
        case .success(let value):
            print("Response Value: \(value)")
        case .failure(let error):
            print("Error: \(error)")
        }
        if let data = response.data, let str = String(data: data, encoding: .utf8) {
            print("Raw Response Data: \(str)")
        }
    }

    private func getCallerInfo() -> String {
        let stackSymbols = Thread.callStackSymbols
        // 跳过前几个堆栈帧，这些通常是 Alamofire 内部的调用
        for symbol in stackSymbols.dropFirst(4) {
            if let range = symbol.range(of: "ESPAPIManager"),
               let methodStart = symbol.range(of: " "),
               let methodEnd = symbol.range(of: "]", options: .backwards) {
                let methodName = symbol[methodStart.upperBound..<methodEnd.lowerBound].trimmingCharacters(in: .whitespaces)
                return "ESPAPIManager.\(methodName)"
            }
        }
        return "Unknown caller"
    }
}
