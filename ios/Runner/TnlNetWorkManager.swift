//
//  TnlNetWorkManager.swift
//  Runner
//
//  Created by Tnluser on 03/08/23.
//

import Foundation
import Alamofire


@objc open class TLRequestConfig: NSObject {
    
    var headers: [String : String] = [:]
    @objc  var urlString: String = ""
    var requestMethod: HTTPMethod = .get
    var typeFileDownload: Bool = false
    var bodyParams: [String : AnyObject]? = [:]
    var bodyParamsData: Data?
    var bodyParamsAnyObject: AnyObject?
    var timeoutInterval = 60.0
    var retryCount = 0
    @objc var eTagFlag: Bool = false
    @objc var readResponseHeader: Bool = false
    
    
    @objc public init(completeUrl: String, requestHeaders: [String : String], requestType: TLRequestType, params: [String : AnyObject]?) {


        self.headers = requestHeaders
        self.urlString = completeUrl
        self.requestMethod = requestType.getRequestType()
        self.bodyParams = params

    }
}
