//
//  NetworkLoggerModel.swift
//  Byjus_Staging
//
//  Created by Saurav Kumar on 19/12/22.
//  Copyright © 2022 Think & Learn Pvt Ltd. All rights reserved.
//

import Foundation
import Alamofire

final class TLNetworkLoggerService {
    
    public static let sharedManager = TLNetworkLoggerService()
    private init(){ }
    private var data: [TLNetWorkData] = []
    private let lock = NSLock()
    
    func setValue(response: Any, bodyParam: TLRequestConfig) {
        lock.lock()
        self.setNetworkData(with: response, bodyParam: bodyParam)
        lock.unlock()
    }
    
    private func setNetworkData(with response: Any,  bodyParam: TLRequestConfig) {
       
        var netWorkData = TLNetWorkData()
        
        if let response = response as? DataResponse<Any> {
            
            if let allHTTPHeaderFields = response.request!.allHTTPHeaderFields{
                netWorkData.allHTTPHeaderFields = allHTTPHeaderFields
            }
            
            if let bodyParams = bodyParam.bodyParams {
                netWorkData.bodyParams = bodyParams
            }
            
            if let bodyParamsData = bodyParam.bodyParamsData {
                netWorkData.bodyParamsData = bodyParamsData
            }
            
            if let bodyParamsAnyObject = bodyParam.bodyParamsAnyObject {
                netWorkData.bodyParamsAnyObject = bodyParamsAnyObject
            }
            
            if let headerFields = response.response?.allHeaderFields{
                netWorkData.header = headerFields
            }
            
            if let statusCode = response.response?.statusCode{
                netWorkData.statusCode = statusCode
            }
            
            netWorkData.totalDuration = response.timeline.totalDuration
            
            let value = response.result
            if value.isSuccess {
                netWorkData.response = getJsonString(data: value.value, originalReponse: response)
            } else {
                netWorkData.response = value.error?.localizedDescription
            }
            
        } else if let response = response as? DataResponse<Data> {
            
            netWorkData.totalDuration = response.timeline.totalDuration
            
            netWorkData.header = bodyParam.headers
            let value = response.result
            if value.isSuccess {
                netWorkData.response = getJsonString(data: value.value, originalReponse: response)
                
            } else {
                netWorkData.response = value.error?.localizedDescription
            }
        }

        netWorkData.url = bodyParam.urlString
        netWorkData.method = bodyParam.requestMethod.rawValue
        netWorkData.time = getTime()
        netWorkData.originalResponse = response
        
        self.data.insert(netWorkData, at: 0)
    }
    
    func getJsonString(data: Any?, originalReponse: Any?) -> String {
        if let body = data as? [String: Any] {
            return body.json
        } else if let body = data as? String {
            return body
        }
        return "\(String(describing: originalReponse))"
    }
    
    func getObject() -> [TLNetWorkData] {
        lock.lock()
        let networkData = data
        lock.unlock()
        return networkData
    }
    
    func reset() {
        lock.unlock()
        data.removeAll()
        lock.unlock()
    }
    
    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm:ss a"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }
}

struct TLNetWorkData {
    var url: String?
    var header: [AnyHashable : Any]?
    var allHTTPHeaderFields: [String: String]?
    var bodyParams: [String: Any]?
    var statusCode: Int?
    var response: String?
    var method: String?
    var bodyParamsData: Data?
    var bodyParamsAnyObject: AnyObject?
    var time: String?
    var originalResponse: Any?
    var totalDuration: TimeInterval?
}

extension Collection {
    
    /// Returns: the pretty printed JSON string or an error string if any error occur.
    var json: String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            return "json serialization error: \(error)"
        }
    }
}
