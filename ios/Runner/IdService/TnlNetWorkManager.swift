//
//  TLServiceManager.swift
//  ThinkandLearn
//
//  Created by abhijit on 28/01/16.
//  Copyright © 2016 T&L. All rights reserved.
//

import UIKit
import Alamofire

let kEtagKeyDictionary = "kEtagKeyDictionaryForAPIs"
let kResponseHeaderKey = "kResponseHeaderForAPIs"

public enum NetworkResult<Success, Failure> where Failure: Error {
    case success(Success)
    case failure(Failure)
}

@objc public enum TLRequestType: Int {

    case post
    case get
    case patch
    case delete
    case put
    
    func getRequestType() -> HTTPMethod {

        switch self.rawValue {
        case TLRequestType.post.rawValue:
            return .post
        case TLRequestType.get.rawValue:
            return .get
        case TLRequestType.patch.rawValue:
            return .patch
        case TLRequestType.delete.rawValue:
            return .delete
        case TLRequestType.put.rawValue:
            return .put
        default:
            return .get
        }
    }
}

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
        
    @objc public init(requestHeadersForScalyr: [String : String], url: String, requestType: TLRequestType, params: [String : AnyObject]? ) {

           self.headers = requestHeadersForScalyr
           self.urlString = url
           self.requestMethod = requestType.getRequestType()
           self.bodyParams = params
       }
    
    
    @objc public init(completeUrl: String, requestHeaders: [String : String], requestType: TLRequestType, params: [String : AnyObject]?) {


        self.headers = requestHeaders
        self.urlString = completeUrl
        self.requestMethod = requestType.getRequestType()
        self.bodyParams = params

    }
    
    @objc public init(completeUrl: String, requestHeaders: [String : String], requestType: TLRequestType, params: [String : AnyObject]?, timeoutInterval : Double) {


        self.headers = requestHeaders
        self.urlString = completeUrl
        self.requestMethod = requestType.getRequestType()
        self.bodyParams = params
         self.timeoutInterval = timeoutInterval

    }
  
    
    @objc public init(headers: [String : String], requestUrl: String, requestType: TLRequestType, params: AnyObject? ) {
        
        self.headers = headers
        self.urlString = requestUrl
        self.requestMethod = requestType.getRequestType()
        self.bodyParams = nil
        self.bodyParamsData = nil
        self.bodyParamsAnyObject = params
    }

    @objc public init(completeUrl: String, requestHeaders: [String : String], requestType: TLRequestType, params: [String : AnyObject]?, retryCount: Int) {
        self.headers = requestHeaders
        self.urlString = completeUrl
        self.requestMethod = requestType.getRequestType()
        self.bodyParams = params
        self.retryCount = retryCount
    }
}

@objc class TLNetworkManager: NSObject {
    
    fileprivate class func saveRequestEtagWithData(_ responseHeader: [AnyHashable: Any]?, requestUrl: String) {

        if let headerDictionary = responseHeader {
            if let etagValue = headerDictionary["Etag"] {
                var etagVal = (etagValue as? String)?.replacingOccurrences(of: "W/", with: "")
                //var etagVal = (etagValue as? String)?.replacingOccurrences(of: "W/", with: "", options: NSString.CompareOptions.literal, range: nil)
                etagVal = etagVal?.replacingOccurrences(of: "\"", with: "")
                if let etagVal = etagVal {
                    
                    var dictionary = UserDefaults.standard.dictionary(forKey: kEtagKeyDictionary)
                    if dictionary != nil {
                    
                        dictionary?[requestUrl] = etagVal
                    }
                    else {
                    
                        dictionary = Dictionary()
                        dictionary?[requestUrl] = etagVal
                    }
                    UserDefaults.standard.setValue(dictionary, forKeyPath: kEtagKeyDictionary)
                    UserDefaults.standard.synchronize()
                }
            }
        }
    }

    @objc class func requestForConfigInBackground(_ serviceType: TLRequestConfig, completionBlock :@escaping (_ response: Dictionary<String, AnyObject>?, _ error: NSError?) -> ()) {
                
        let requestURL = URL(string: serviceType.urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        
        print("requestURL------------:",requestURL?.absoluteString)
        
        if let requestURL = requestURL {
            
            //If Etag is enable, set the tag in header
            if serviceType.eTagFlag == true {
                
                if let eTag = TLNetworkManager.getRequestEtagWithDataForUrl(requestURL.absoluteString){
                    serviceType.headers["if-none-match"] = eTag
                }
            }
            
            //Create urlRequest
            var urlRequest = URLRequest(url: requestURL, cachePolicy:.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: serviceType.timeoutInterval)
            urlRequest.allHTTPHeaderFields = serviceType.headers
            urlRequest.httpMethod = serviceType.requestMethod.rawValue
            
            //Set the body -
            if let body = serviceType.bodyParamsData{
                
                urlRequest.httpBody = body
                
            }else if let body = serviceType.bodyParams {
                urlRequest.httpBody =  try! JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            }
            
            let queue = DispatchQueue.global(qos: .background)
            Alamofire.request(urlRequest).responseJSON(queue: queue, options: .allowFragments, completionHandler: { response in
                DispatchQueue.main.async {
                    print(response)
                    print(response.request!)
                    
                    if let allHTTPHeaderFields = response.request!.allHTTPHeaderFields{
                        
                        print(allHTTPHeaderFields)
                    }
                    if let bodyParams = serviceType.bodyParams{
                        print(bodyParams)
                    }
                    
                    if let headerFields = response.response?.allHeaderFields{
                        
                        print(headerFields)
                    }
                    
                    if let statusCode = response.response?.statusCode{
                        
                        print("Status --", statusCode)
                    }
                        
                   // TLNetworkLoggerService.sharedManager.setValue(response: response, bodyParam: serviceType)
                    
                    switch response.result {
                        
                    case .success(let value):
                        
                        if let responseValue = value as? Dictionary<String, AnyObject> {
                            let (success, errorObject) = TLNetworkManager.validateResponse(responseValue, serviceType: serviceType)
                            if success {
                                //exceptional case reading response from header done only to support legacy apis from sever like course data where json contract is not getting updated from the server - course data ab - couseid and name fetch for olap
                                if serviceType.readResponseHeader == true{
                                    TLNetworkManager.saveResponseHeaderWithData(response.response?.allHeaderFields, requestUrl: requestURL.absoluteString)
                                }
                                completionBlock(responseValue, nil)
                                
                                if serviceType.eTagFlag == true {
                                    //Save the tag if any
                                    TLNetworkManager.saveRequestEtagWithData(response.response?.allHeaderFields, requestUrl:requestURL.absoluteString)
                                }
                            } else {
                                completionBlock(nil, errorObject)
                            }
                        }
                        else {
                            
                            var newResponseValue = Dictionary<String, AnyObject>()
                            newResponseValue["response"] = value as? AnyObject
                            let (success, errorObject) = TLNetworkManager.validateResponse(newResponseValue, serviceType: serviceType)
                            if success {
                                //exceptional case reading response from header done only to support legacy apis from sever like course data where json contract is not getting updated from the server - course data ab - couseid and name fetch for olap
                                                      if serviceType.readResponseHeader == true{
                                                          TLNetworkManager.saveResponseHeaderWithData(response.response?.allHeaderFields, requestUrl: requestURL.absoluteString)
                                                      }
                                completionBlock(newResponseValue, nil)
                                
                                if serviceType.eTagFlag == true {
                                    //Save the tag if any
                                    TLNetworkManager.saveRequestEtagWithData(response.response?.allHeaderFields, requestUrl:requestURL.absoluteString)
                                }
                            } else {
                                completionBlock(nil, errorObject)
                            }
                        }
                        
                    case .failure(let error):
                        if response.response?.statusCode == 200 || response.response?.statusCode == 304 || response.response?.statusCode == 201 {
                            print(error.localizedDescription)
                            completionBlock(nil, nil)
                            
                        } else {
                            completionBlock(nil, error as NSError?)
                        }
                        
                    }
                }
                
            })
        } else {
            let error = NSError(domain: "Server Error", code:123, userInfo : nil)
            completionBlock(nil, error)
        }
        
    }
    @objc class func requestForConfigIDService(_ serviceType: TLRequestConfig, completionBlock :@escaping (_ response: Dictionary<String, AnyObject>?, _ error: NSError?, _ responseHeaders:Dictionary<String, AnyObject>?) -> ()) {

        var urlString = serviceType.urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let allowedCharacterSet = (CharacterSet(charactersIn: "+").inverted)
        urlString = urlString?.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
        if let urlString = urlString, let requestURL = URL(string: urlString) {
            
            
            print("requestURL------------:",urlString)

            //If Etag is enable, set the tag in header
            if serviceType.eTagFlag == true {
                
                if let eTag = TLNetworkManager.getRequestEtagWithDataForUrl(requestURL.absoluteString){
                    serviceType.headers["if-none-match"] = eTag
                }
            }

            //Create urlRequest
            var urlRequest = URLRequest(url: requestURL, cachePolicy:.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: serviceType.timeoutInterval)
            urlRequest.allHTTPHeaderFields = serviceType.headers
            urlRequest.httpMethod = serviceType.requestMethod.rawValue
            
            //Set the body -
            if let body = serviceType.bodyParamsData{
                
                urlRequest.httpBody = body
                
            }else if let body = serviceType.bodyParams {
                urlRequest.httpBody =  try! JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            } else if let body = serviceType.bodyParamsAnyObject {
                urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            }
            let session = SessionManager.default
            if serviceType.retryCount != 0 {
                let retrier = TLRequestRetrier()
                retrier.retryLimit = serviceType.retryCount
                session.retrier = retrier
                let adapter = TLRequestAdapter()
                session.adapter = adapter
            } else {
                session.retrier = nil
                session.adapter = nil
            }
            
            session.request(urlRequest).responseJSON { response in
            //Request
            //Alamofire.request(urlRequest) .responseJSON { response in
                print(response)
               
                if let allHTTPHeaderFields = response.request!.allHTTPHeaderFields{
                
                     print(allHTTPHeaderFields)
                }
                if let bodyParams = serviceType.bodyParams{
                    print(bodyParams)
                }
               
                if let headerFields = response.response?.allHeaderFields{
            
                    print(headerFields)
                }
                
                if let statusCode = response.response?.statusCode{
                
                     print("Status --", statusCode)
                }
                
                // To log Network
                TLNetworkLoggerService.sharedManager.setValue(response: response, bodyParam: serviceType)
                
                switch response.result {

                case .success(let value):

                    if let responseValue = value as? Dictionary<String, AnyObject> {
                        let (success, errorObject) = TLNetworkManager.validateResponse(responseValue, serviceType: serviceType)
                        if success {
                            //exceptional case reading response from header done only to support legacy apis from sever like course data where json contract is not getting updated from the server - course data ab - couseid and name fetch for olap
                                                       if serviceType.readResponseHeader == true{
                                                           TLNetworkManager.saveResponseHeaderWithData(response.response?.allHeaderFields, requestUrl: requestURL.absoluteString)
                                                       }
                            completionBlock(responseValue, nil, response.response?.allHeaderFields as? Dictionary<String, AnyObject>)

                            if serviceType.eTagFlag == true {
                                //Save the tag if any
                             TLNetworkManager.saveRequestEtagWithData(response.response?.allHeaderFields, requestUrl:requestURL.absoluteString)
                            }
                        } else {
                            completionBlock(nil, errorObject, nil)
                        }
                    }
                    else {
                        
                        var newResponseValue = Dictionary<String, AnyObject>()
                        newResponseValue["response"] = value as? AnyObject
                        let (success, errorObject) = TLNetworkManager.validateResponse(newResponseValue, serviceType: serviceType)
                        if success {
                            //exceptional case reading response from header done only to support legacy apis from sever like course data where json contract is not getting updated from the server - course data ab - couseid and name fetch for olap
                            if serviceType.readResponseHeader == true{
                                TLNetworkManager.saveResponseHeaderWithData(response.response?.allHeaderFields, requestUrl: requestURL.absoluteString)
                            }

                            completionBlock(newResponseValue, nil, response.response?.allHeaderFields as? Dictionary<String, AnyObject>)
                            
                            if serviceType.eTagFlag == true {
                                //Save the tag if any
                                TLNetworkManager.saveRequestEtagWithData(response.response?.allHeaderFields, requestUrl:requestURL.absoluteString)
                            }
                        } else {
                            completionBlock(nil, errorObject, nil)
                        }
                    }

                case .failure(let error):

                    if response.response?.statusCode == 200 || response.response?.statusCode == 304 || response.response?.statusCode == 201 {
                        print(error.localizedDescription)
                        completionBlock(nil, nil, nil)

                    } else {
                         completionBlock(nil, error as NSError?, nil)
                    }

                }
            }


        } else {
            let error = NSError(domain: "Server Error", code:123, userInfo : nil)
            completionBlock(nil, error, nil)
        }

    }
    
    fileprivate class func getRequestEtagWithDataForUrl(_ requestUrl: String) -> String?{
    
        
        var dictionary = UserDefaults.standard.dictionary(forKey: kEtagKeyDictionary)
        return dictionary?[requestUrl] as? String
        
    }

    @objc class func requestForConfig(_ serviceType: TLRequestConfig, completionBlock :@escaping (_ response: Dictionary<String, AnyObject>?, _ error: NSError?) -> ()) {

        var urlString = serviceType.urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let allowedCharacterSet = (CharacterSet(charactersIn: "+").inverted)
        urlString = urlString?.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
        if let urlString = urlString, let requestURL = URL(string: urlString) {
            
            
            print("requestURL------------:",urlString)

            //If Etag is enable, set the tag in header
            if serviceType.eTagFlag == true {
                
                if let eTag = TLNetworkManager.getRequestEtagWithDataForUrl(requestURL.absoluteString){
                    serviceType.headers["if-none-match"] = eTag
                }
            }

            //Create urlRequest
            var urlRequest = URLRequest(url: requestURL, cachePolicy:.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: serviceType.timeoutInterval)
            urlRequest.allHTTPHeaderFields = serviceType.headers
            urlRequest.httpMethod = serviceType.requestMethod.rawValue
            
            //Set the body -
            if let body = serviceType.bodyParamsData{
                
                urlRequest.httpBody = body
                
            }else if let body = serviceType.bodyParams {
                urlRequest.httpBody =  try! JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            } else if let body = serviceType.bodyParamsAnyObject {
                urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            }
            let session = SessionManager.default
            if serviceType.retryCount != 0 {
                let retrier = TLRequestRetrier()
                retrier.retryLimit = serviceType.retryCount
                session.retrier = retrier
                let adapter = TLRequestAdapter()
                session.adapter = adapter
            } else {
                session.retrier = nil
                session.adapter = nil
            }
            
            session.request(urlRequest).responseJSON { response in
            //Request
            //Alamofire.request(urlRequest) .responseJSON { response in
                print(response)
               
                if let allHTTPHeaderFields = response.request!.allHTTPHeaderFields{
                     print(allHTTPHeaderFields)
                }
                if let bodyParams = serviceType.bodyParams{
                    print(bodyParams)
                }
               
                if let headerFields = response.response?.allHeaderFields{
                    print(headerFields)
                }
                
                if let statusCode = response.response?.statusCode{
                     print("Status --", statusCode)
                }
                
                // To Log Network
                TLNetworkLoggerService.sharedManager.setValue(response: response, bodyParam: serviceType)
                
                switch response.result {

                case .success(let value):

                    if let responseValue = value as? Dictionary<String, AnyObject> {
                        let (success, errorObject) = TLNetworkManager.validateResponse(responseValue, serviceType: serviceType)
                        if success {
                            //exceptional case reading response from header done only to support legacy apis from sever like course data where json contract is not getting updated from the server - course data ab - couseid and name fetch for olap
                                                       if serviceType.readResponseHeader == true{
                                                           TLNetworkManager.saveResponseHeaderWithData(response.response?.allHeaderFields, requestUrl: requestURL.absoluteString)
                                                       }
                            completionBlock(responseValue, nil)

                            if serviceType.eTagFlag == true {
                                //Save the tag if any
                             TLNetworkManager.saveRequestEtagWithData(response.response?.allHeaderFields, requestUrl:requestURL.absoluteString)
                            }
                        } else {
                            completionBlock(nil, errorObject)
                        }
                    }
                    else {
                        
                        var newResponseValue = Dictionary<String, AnyObject>()
                        newResponseValue["response"] = value as? AnyObject
                        let (success, errorObject) = TLNetworkManager.validateResponse(newResponseValue, serviceType: serviceType)
                        if success {
                            //exceptional case reading response from header done only to support legacy apis from sever like course data where json contract is not getting updated from the server - course data ab - couseid and name fetch for olap
                            if serviceType.readResponseHeader == true{
                                TLNetworkManager.saveResponseHeaderWithData(response.response?.allHeaderFields, requestUrl: requestURL.absoluteString)
                            }

                            completionBlock(newResponseValue, nil)
                            
                            if serviceType.eTagFlag == true {
                                //Save the tag if any
                                TLNetworkManager.saveRequestEtagWithData(response.response?.allHeaderFields, requestUrl:requestURL.absoluteString)
                            }
                        } else {
                            completionBlock(nil, errorObject)
                        }
                    }

                case .failure(let error):

                    if response.response?.statusCode == 200 || response.response?.statusCode == 304 || response.response?.statusCode == 201 {
                        print(error.localizedDescription)
                        completionBlock(nil, nil)

                    } else {
                         completionBlock(nil, error as NSError?)
                    }

                }
            }


        } else {
            let error = NSError(domain: "Server Error", code:123, userInfo : nil)
            completionBlock(nil, error)
        }

    }
    
    


      class func validateResponse(_ responseDict: Dictionary<String, AnyObject>?, serviceType: TLRequestConfig) -> (success: Bool, error: NSError?) {

        if let responseDict = responseDict {
            if let errorDict = responseDict["error"] as? NSDictionary {
                //Changed error code  to Int for v4
                let code = errorDict["code"] as? Int
                let message = errorDict ["message"] as? String
                let reason = errorDict["title"] as? String
                var error: NSError?
                if  let message = message {
                    let userInfo: [AnyHashable: Any] =
                    [
                        NSLocalizedDescriptionKey : message,
                        NSLocalizedFailureReasonErrorKey : reason ?? ""
                    ]
                    if let codeVal = code {
                        if(codeVal == 11103) {
//                            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationInvalidSessionForK3), object:nil)
//                            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationInvalidSession), object:nil)
                        }
                        error = NSError(domain: "Server Error", code:codeVal, userInfo : userInfo as! [String : Any])
                    } else {
                        error = NSError(domain: "Server Error", code:123, userInfo : userInfo as! [String : Any])
                    }
                } else {
                    error = NSError(domain: "Server Error", code:123, userInfo : nil)
                }
                return (success:false, error:error)
            } else {
                return (success:true, error:nil)
            }
//            if serviceType.typeFileDownload {
//               return (success:true, error:nil)
//            }
        }
        return (success:false, error:NSError(domain: "Server Error", code:123, userInfo : nil))
    }

    
        @objc class func saveResponseHeaderWithData(_ responseHeader: [AnyHashable: Any]?, requestUrl: String) {

        if let headerDictionary = responseHeader {
            var dictionary = UserDefaults.standard.dictionary(forKey: kResponseHeaderKey)
            if dictionary != nil {
            
                dictionary?[requestUrl] = headerDictionary
            }
            else {
            
                dictionary = Dictionary()
                dictionary?[requestUrl] = headerDictionary
            }
            UserDefaults.standard.setValue(dictionary, forKeyPath: kResponseHeaderKey)
            UserDefaults.standard.synchronize()
        }
    }
}


private extension UserDefaults {

    subscript(eTag: String) -> String? {
        get {
            let dictionary = self.object(forKey: "network_etags_values") as? [String:String]
            if let eTagDict = dictionary {
                if let eTagValue = eTagDict[eTag] {
                    return eTagValue
                }
            }
            return nil
        }
        set {

            var tagDictionary = self.object(forKey: "network_etags_values") as? [String:String]
            if tagDictionary == nil {
                tagDictionary = [:]
                self.set(tagDictionary, forKey: "network_etags_values")
            }

            if let v = newValue {
                tagDictionary![eTag] = v
                self.set(tagDictionary, forKey: "network_etags_values")


            }
            self.synchronize()
        }
    }
}

class TLRequestRetrier: RequestRetrier {
    
    var retryLimit = 0
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        guard request.retryCount < retryLimit, error.code == 805408 else {
            print("\nStop here, no retry, \(request.retryCount), \(error.code)\n")
            print("\nrequest, \(request)")
            completion(false, 0.0)
            return
        }
        print("\nretried; retry count: \(request.retryCount), \(error.code)\n")
        completion(true, 0.1)
    }
}

class TLRequestAdapter: RequestAdapter {
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        return urlRequest
    }
}
