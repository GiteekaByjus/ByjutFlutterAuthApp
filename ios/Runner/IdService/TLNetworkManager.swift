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

    @objc public init(requestHeaders: [String : String], url: String, requestType: TLRequestType, params: [String : AnyObject]? ) {

        self.headers = requestHeaders
        self.urlString = kServiceBaseUrl + url
        self.requestMethod = requestType.getRequestType()
        self.bodyParams = params
    }
    
    @objc public init(requestHeadersForScalyr: [String : String], url: String, requestType: TLRequestType, params: [String : AnyObject]? ) {

           self.headers = requestHeadersForScalyr
           self.urlString = url
           self.requestMethod = requestType.getRequestType()
           self.bodyParams = params
       }
    
    
    @objc public init(requestHeaders: [String : String], url: String, requestType: TLRequestType, params: [String : AnyObject]? , timeoutInterval : Double) {

        self.headers = requestHeaders
        self.urlString = kServiceBaseUrl + url
        self.requestMethod = requestType.getRequestType()
        self.bodyParams = params
        self.timeoutInterval = timeoutInterval
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
    @objc public init(requestHeaders: [String : String], url: String, requestType: TLRequestType, paramsData: Data?) {
        
        
        self.headers = requestHeaders
        self.urlString = kServiceBaseUrl + url
        self.requestMethod = requestType.getRequestType()
        self.bodyParamsData = paramsData
        
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

struct Configuration {

    var baseURL: String?
    var iTunesReceiptVerificationURL: String?
    var S3URLForSpecials: String?
    var serviceSchoolURL: String?
    var chatURL: String?
    var olapURL: String?
    var graphAPIURL : String?
    var olapAppID: String?
    var dsslURL: String?
    var homeDemoURL : String?
    var olapCounterExtension: String?
    var olapSessionExtension: String?
    var olapPaymentExtension: String?
    var olapUserExtension: String?
    var featureVersion: String?
    var graphQuizVersion: String?
    var appID: String?
    var placesAPIURL : String?
    var questionsManifestURL: String?
    var webBundleVersion: String?
    var mapSecretKey: String?
    var slapiBaseURL : String?
    var webinarURL: String?
    var byjusYoungGenius: String?
    var abTestingKey: String?
    var premiumSchoolBaseURL: String?
    var agoraAppId: String?
    var agoraWhiteboardAppId: String?
    var premiumSchoolChatURL: String?
    var premiumSchoolWebAssignmentURL: String?
    var premiumSchoolFetchChatURL: String?
    var identityProfileType: String?
    var neoChatURL: String?
    var sduiBaseUrl: String?
    var neoPollURL: String?
    var neoIQURL: String?
    var classesBaseURL: String?
    var staticS3ImagesBaseURL: String?
    var textBookBaseURL: String?
    var accountDeletionBaseURL: String?
    var homeworkAssessmentBaseURL : String?
    var widgetBaseURL: String?
    var classesAppSyncURL: String?
    var pfBaseURL: String?
    var liveQuizAPIURL: String?
    var liveQuizWebViewURL: String?
    var liveQuizSDKTenantId: String?
    var devAutoSolver: String?
    var eventRegistrationSDKURL: String?
    var neoBaseURL: String?
    var neoWhiteboardChatURL: String?
    var uploadDocumentBaseUrl: String?
    var uploadDocumentAuthTocken: String?
    
    init() {

        print("**** getConfigurations ****")
        if let path = Bundle.main.path(forResource: "TLConfiguration", ofType: "plist") {

            let configurations =  NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject>

            if let baseURL = configurations?["baseURL"] as? String {
                self.baseURL = baseURL
            }
            if let iTunesReceiptVerificationURL = configurations?["iTunesReceiptVerificationURL"] as? String {
                self.iTunesReceiptVerificationURL = iTunesReceiptVerificationURL
            }
            if let S3URLForSpecials = configurations?["S3URLForSpecials"] as? String {
                self.S3URLForSpecials = S3URLForSpecials
            }
            if let olapURL = configurations?["olapURL"] as? String {
                self.olapURL = olapURL
            }
            if let graphAPIURL = configurations?["graphAPIURL"] as? String {
                self.graphAPIURL = graphAPIURL
            }
            if let olapAppID = configurations?["olapAppID"] as? String {
                self.olapAppID = olapAppID
            }
            if let serviceSchoolURL = configurations?["serviceSchoolUrl"] as? String {
                self.serviceSchoolURL = serviceSchoolURL
            }
            if let chatURL = configurations?["chatURL"] as? String {
                self.chatURL = chatURL
            }
            if let dsslURL = configurations?["dsslURL"] as? String {
                self.dsslURL = dsslURL
            }
            if let homeDemoURL = configurations?["homeDemoURL"] as? String {
                self.homeDemoURL = homeDemoURL
            }
            if let olapCounterExtension = configurations?["olapCounterExtension"] as? String {
                self.olapCounterExtension = olapCounterExtension
            }
            if let olapSessionExtension = configurations?["olapSessionExtension"] as? String {
                self.olapSessionExtension = olapSessionExtension
            }
            if let olapPaymentExtension = configurations?["olapPaymentExtension"] as? String {
                self.olapPaymentExtension = olapPaymentExtension
            }
            if let olapUserExtension = configurations?["olapUserExtension"] as? String {
                self.olapUserExtension = olapUserExtension
            }
            if let featureVersion = configurations?["featureVersion"] as? String {
                self.featureVersion = featureVersion
            }
            if let graphQuizVersion = configurations?["graphQuizVersion"] as? String {
                self.graphQuizVersion = graphQuizVersion
            }
            if let appID = configurations?["appID"] as? String {
                self.appID = appID
            }
            if let placesAPIURL = configurations?["placesAPIURL"] as? String {
                self.placesAPIURL = placesAPIURL
            }
            if let questionsManifestURL = configurations?["questionsManifestURL"] as? String {
                self.questionsManifestURL = questionsManifestURL
            }
            if let webBundleVersion = configurations?["webBundleVersion"] as? String {
                self.webBundleVersion = webBundleVersion
            }
            
            if let slapiBaseURL = configurations?["slapiBaseURL"] as? String {
                self.slapiBaseURL = slapiBaseURL
            }
            
            if let webinarURL = configurations?["webinarURL"] as? String {
                self.webinarURL = webinarURL
            }
            if let byjusYoungGenius = configurations?["byjusYoungGeniusURL"] as? String {
                self.byjusYoungGenius = byjusYoungGenius
            }
            if let abTestingKey = configurations?["abTestingKey"] as? String {
                self.abTestingKey = abTestingKey
            }
            if let mapSecretKey = configurations?["mapSecretKey"] as? String {
                self.mapSecretKey = mapSecretKey
            }
            if let premiumSchoolBaseURL = configurations?["premiumSchoolBaseURL"] as? String {
                self.premiumSchoolBaseURL = premiumSchoolBaseURL
            }
            if let agoraAppId = configurations?["agoraAppId"] as? String {
                self.agoraAppId = agoraAppId
            }
            if let agoraWhiteboardAppId = configurations?["agoraWhiteboardAppId"] as? String {
                self.agoraWhiteboardAppId = agoraWhiteboardAppId
            }
            if let premiumSchoolChatURL = configurations?["premiumSchoolChatURL"] as? String {
                self.premiumSchoolChatURL = premiumSchoolChatURL
            }
            if let premiumSchoolWebAssignmentURL = configurations?["premiumSchoolWebAssignmentURL"] as? String {
                self.premiumSchoolWebAssignmentURL = premiumSchoolWebAssignmentURL
            }
            if let premiumSchoolFetchChatURL = configurations?["premiumSchoolFetchChatURL"] as? String {
                self.premiumSchoolFetchChatURL = premiumSchoolFetchChatURL
            }
            if let identityProfileType = configurations?["identityProfileType"] as? String {
                self.identityProfileType = identityProfileType
            }
            if let neoChatURL = configurations?["neoChatURL"] as? String {
                self.neoChatURL = neoChatURL
            }
            if let sduiBaseUrl = configurations?["sduiBaseUrl"] as? String {
                self.sduiBaseUrl = sduiBaseUrl
            }
            if let neoPollURL = configurations?["neoPollURL"] as? String {
                self.neoPollURL = neoPollURL
            }
            if let neoIQURL = configurations?["neoIQURL"] as? String {
                self.neoIQURL = neoIQURL
            }
            if let classesBaseURL = configurations?["classesBaseURL"] as? String {
                self.classesBaseURL = classesBaseURL
            }
            if let staticS3ImagesBaseURL = configurations?["staticS3ImagesBaseURL"] as? String {
                self.staticS3ImagesBaseURL = staticS3ImagesBaseURL
            }
            if let textBookBaseURL = configurations?["textBookBaseURL"] as? String {
                self.textBookBaseURL = textBookBaseURL
            }
            if let accountDeletionBaseURL = configurations?["accountDeletionBaseURL"] as? String {
                self.accountDeletionBaseURL = accountDeletionBaseURL
            }
            if let homeworkAssessmentBaseURL = configurations?["homeworkAssessmentBaseURL"] as? String {
                self.homeworkAssessmentBaseURL = homeworkAssessmentBaseURL
            }
            if let widgetBaseURL = configurations?["widgetBaseURL"] as? String {
                self.widgetBaseURL = widgetBaseURL
            }
            if let classesAppSyncURL = configurations?["classesAppSyncURL"] as? String {
                self.classesAppSyncURL = classesAppSyncURL
            }
            
            if let  liveQuizAPIURL = configurations?["liveQuizAPIURL"] as? String {
                self.liveQuizAPIURL = liveQuizAPIURL
            }
            
            if let  liveQuizWebViewURL = configurations?["liveQuizWebViewURL"] as? String {
                self.liveQuizWebViewURL = liveQuizWebViewURL
            }

            if let liveQuizSDKTenantId = configurations?["liveQuizSDKTenantId"] as? String {
                self.liveQuizSDKTenantId = liveQuizSDKTenantId
            }

            if let eventRegistrationSDKURL = configurations?["eventRegistrationSDKURL"] as? String {
                self.eventRegistrationSDKURL = eventRegistrationSDKURL
            }

            if let devAutoSolverURL = configurations?["devAutoSolver"] as? String {
                self.devAutoSolver = devAutoSolverURL
            }
                
            if let neoBaseURL = configurations?["neoBaseURL"] as? String {
                self.neoBaseURL = neoBaseURL
            }
            if let neoWhiteboardChatURL = configurations?["neoWhiteboardChatURL"] as? String {
                self.neoWhiteboardChatURL = neoWhiteboardChatURL
            }
            
            if let uploadDocumentBaseUrl = configurations?["uploadDocumentBaseUrl"] as? String {
                self.uploadDocumentBaseUrl = uploadDocumentBaseUrl
            }
            
            if let uploadDocumentAuthTocken = configurations?["uploadDocumentAuthTocken"] as? String {
                self.uploadDocumentAuthTocken = uploadDocumentAuthTocken
            }
        }
    }
}

@objc public class TLWhiteBoardAppCofig: NSObject {
    @objc public static let agoraWhiteboardAppId = kAgoraWhiteboardAppId
}

let configuration = Configuration()
let kServiceBaseUrl = configuration.baseURL ?? ""
let kServiceS3BaseUrl = configuration.S3URLForSpecials ?? ""
let kServiceSchoolUrl = configuration.serviceSchoolURL ?? ""
let kChatUrl = configuration.chatURL ?? ""
let kSLApiBaseUrl = configuration.slapiBaseURL ?? ""
let kpremiumSchoolBaseURL = configuration.premiumSchoolBaseURL ?? ""
let kAgoraAppId = configuration.agoraAppId ?? ""
let kAgoraWhiteboardAppId = configuration.agoraWhiteboardAppId
let kPremiumSchoolChatURL = configuration.premiumSchoolChatURL
let kPremiumSchoolFetchChatURL = configuration.premiumSchoolFetchChatURL ?? ""
let kNeoChatURL = configuration.neoChatURL
let kSDUIBaseURL = configuration.sduiBaseUrl
let kNeoPollURL = configuration.neoPollURL
let kClassesBaseURL = configuration.classesBaseURL ?? ""//created since kServiceBaseUrl already present with version
let kNeoIQURL = configuration.neoIQURL
let kStaticS3ImagesBaseURL = configuration.staticS3ImagesBaseURL
let kTextbookBaseUrl = configuration.textBookBaseURL ?? "https://dev.byjusweb.com/"
let kHomeworkAssessmentBaseUrl = configuration.homeworkAssessmentBaseURL ?? ""
let kAccountDeletionBaseURL = configuration.accountDeletionBaseURL ?? ""
let kWidgetBaseURL = configuration.widgetBaseURL ?? ""
let kClassesAppSyncURL = configuration.classesAppSyncURL
let kPfBaseURL = configuration.pfBaseURL
let KliveQuizURL = configuration.liveQuizAPIURL ?? ""
let KliveQuizWebViewURL = configuration.liveQuizWebViewURL ?? ""
let KliveQuizSDKTenantId = configuration.liveQuizSDKTenantId ?? ""
let KdevAutoSolver = configuration.devAutoSolver ?? ""
let KQnaSearchBaseURL = configuration.textBookBaseURL ?? "https://dev.byjusweb.com/" // both are the same for textbook and qna
let kNeoBaseURL = configuration.neoBaseURL ?? ""
let kUploadDocumentBaseUrl = configuration.uploadDocumentBaseUrl ?? ""
let kUploadDocumentAuthTocken = configuration.uploadDocumentAuthTocken ?? ""
let kNeoWhiteboardChatURL = configuration.neoWhiteboardChatURL ?? ""

@objc class TLNetworkManager: NSObject {
    
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
    
    @objc class func requestForConfigWithFormData(serviceType: TLRequestConfig, completionBlock :@escaping (_ response: Dictionary<String, AnyObject>?, _ error: NSError?) -> ()) {
        
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
            
            Alamofire.upload(
                    multipartFormData: { multipartFormData in
                        for (key, value) in serviceType.bodyParams! {
                            if key == "image", let data = value as? Data {
                                multipartFormData.append(data, withName: "file",fileName: "file.png", mimeType: "image/png")
                            } else {
                                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                        }
                    }
                },
                to: serviceType.urlString,
                headers: serviceType.headers,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            
                            // To log Network Data
                            TLNetworkLoggerService.sharedManager.setValue(response: response, bodyParam: serviceType)
                            
                            if let responseValue = response.result.value as? Dictionary<String, AnyObject> {
                                let (success, errorObject) = TLNetworkManager.validateResponse(responseValue, serviceType: serviceType)
                                if success {
                                    completionBlock(responseValue, nil)
                                    if serviceType.eTagFlag == true {
                                        TLNetworkManager.saveRequestEtagWithData(response.response?.allHeaderFields, requestUrl:requestURL.absoluteString)
                                    }
                                } else {
                                    completionBlock(nil, errorObject)
                                }
                            } else {
                                let newResponseValue = response.result.value as? Dictionary<String, AnyObject>
                                let (success, errorObject) = TLNetworkManager.validateResponse(newResponseValue, serviceType: serviceType)
                                if success {
                                    if serviceType.readResponseHeader == true{
                                        TLNetworkManager.saveResponseHeaderWithData(response.response?.allHeaderFields, requestUrl: requestURL.absoluteString)
                                    }
                                    completionBlock(newResponseValue, nil)
                                    if serviceType.eTagFlag == true {
                                        TLNetworkManager.saveRequestEtagWithData(response.response?.allHeaderFields, requestUrl:requestURL.absoluteString)
                                    }
                                } else {
                                    completionBlock(nil, errorObject)
                                }
                            }
                        }
                        .uploadProgress { progress in }
                        return
                    case .failure(let encodingError):
                        completionBlock(nil, encodingError as NSError?)
                    }
                })
            
        } else {
            let error = NSError(domain: "Server Error", code:123, userInfo : nil)
            completionBlock(nil, error)
        }
    }
    
    class func requestForData(_ serviceType: TLRequestConfig, completionBlock: @escaping (NetworkResult<Data, Error>)-> ()) {
            
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
                } else if let body = serviceType.bodyParamsAnyObject {
                    urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                }
                
                Alamofire.request(urlRequest).validate().responseData(completionHandler: {
                    response in
                    
                    // To log Network Data
                    TLNetworkLoggerService.sharedManager.setValue(response: response, bodyParam: serviceType)
                    
                    switch response.result {
                    case .success(let data):
                        completionBlock(.success(data))
                    case .failure(let error):
                        completionBlock(.failure(error))
                    }
                })
            }
        }
    
    fileprivate class func getRequestEtagWithDataForUrl(_ requestUrl: String) -> String?{
    
        
        var dictionary = UserDefaults.standard.dictionary(forKey: kEtagKeyDictionary)
        return dictionary?[requestUrl] as? String
        
    }

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
    
    @objc class func getResponseHeaderWithDataForUrl(_ requestUrl: String) -> Dictionary<String, Any>?{
    
        let dictionary = UserDefaults.standard.dictionary(forKey: kResponseHeaderKey)
        return dictionary?[requestUrl] as? Dictionary
        
    }
    
    @objc class func removeResponseHeaderWithData(_ requestUrl: String) {
        
        var dictionary = UserDefaults.standard.dictionary(forKey: kResponseHeaderKey)
        dictionary?.removeValue(forKey: requestUrl)
        UserDefaults.standard.setValue(dictionary, forKeyPath: kResponseHeaderKey)
        UserDefaults.standard.synchronize()

    }



    @objc class func removeRequestEtagWithRequestObject(_ serviceType: TLRequestConfig){
    
        let requestURL = URL(string: serviceType.urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        self.removeRequestEtagWithData(requestURL?.absoluteString ?? "")

    }
    @objc class func removeRequestEtagWithData(_ requestUrl: String) {
        
        var dictionary = UserDefaults.standard.dictionary(forKey: kEtagKeyDictionary)
        dictionary?.removeValue(forKey: requestUrl)
        UserDefaults.standard.setValue(dictionary, forKeyPath: kEtagKeyDictionary)
        UserDefaults.standard.synchronize()

    }
    @objc class func removeAllRequestEtagWithData() {

        var dictionary = UserDefaults.standard.dictionary(forKey: kEtagKeyDictionary)
        if let dict = dictionary{
            for key in (dict.keys) {
                
                //Not deleting Cohort Api call
                let cohortMatched = TLUtilities.matches(for: "/cohorts/\\b([0-9]{0,})\\?json_version=[0-9]", in: key)
               // let settingsMatched = TLUtilities.matches(for: "/cohorts/\\b([0-9]{0,})\\?json_version=[0-9]", in: key)
                if(cohortMatched.count == 0) {
                    
                    dictionary?.removeValue(forKey: key)
                }
                UserDefaults.standard.setValue(dictionary, forKeyPath: kEtagKeyDictionary)
                UserDefaults.standard.synchronize()
                
            }
        }
    }

//    class func uploadForType(_ serviceType: TLRequestConfig, data: Data, jsonKeyName: String, fileName: String, mimeType: String, completionBlock :@escaping (_ response: Dictionary<String, AnyObject>?, _ error: NSError?) -> ()) {
//
//        Alamofire.upload(.POST, serviceType.urlString, headers: serviceType.headers, multipartFormData: {
//            multipartFormData in
//            multipartFormData.appendBodyPart(data: data, name: jsonKeyName, fileName: jsonKeyName, mimeType: mimeType)
//            }, encodingCompletion: {
//                encodingResult in
//                switch encodingResult {
//                case .Success(let uploadResult):
//                    uploadResult.request.responseJSON { response in
//                        print(response)
//                        print(response.request!)
//                        print(response.request!.allHTTPHeaderFields)
//                        switch response.result {
//                        case .Success(let value):
//                            let responseValue = value as? Dictionary<String, AnyObject>
//                            if let responseValue = responseValue {
//                                let (success, errorObject) = TLNetworkManager.validateResponse(responseValue, serviceType: serviceType)
//
//                                if success {
//                                    completionBlock(response: responseValue, error: nil)
//                                } else {
//                                    completionBlock(response: nil, error:errorObject)
//                                }
//                            }
//                        case .Failure(let error):
//                            print(error.userInfo)
//                            completionBlock(response: nil, error: error)
//                        }
//                    }
//                case .Failure(let encodingError):
//                    print(encodingError)
//                }
//        })
//    }

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
                            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationInvalidSessionForK3), object:nil)
                            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationInvalidSession), object:nil)
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





    @objc class func requestImage(_ params: String, completionBlock :@escaping (_ response: AnyObject?, _ error: NSError?) -> ()) {

        Alamofire.request(params).response() { response in
            let data = response.data
            completionBlock(data as AnyObject?, nil)

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
