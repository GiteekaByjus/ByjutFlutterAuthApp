//
//  TNLIDServiceManager.swift
//  ThinkandLearn
//
//  Created by Sarvjeet Singh on 19/03/21.
//  Copyright © 2021 Think & Learn Pvt Ltd. All rights reserved.
//

import Foundation
import AppAuth
//import IDService

@objc public class TNLIDServiceManager : NSObject {
   public var idservice : IDService?
    var otpEndPoint = ""
    var identityEndPoint = ""
    var passcodePolicyEndPoint = ""
    var resendPasscodeEndPoint = ""
    var passcodeInitiateEndPoint = ""
    var tokenInitiateEndPoint = ""
    var updatePasscodeEndPoint = ""
    var validateOtpEndPoint = ""
    #if PREMIUM
    let tokensScopeArr = ["openid", "offline", "identities.read", "accounts.read","identities.update","accounts.update", "identities.delete", "profiles.delete", "passcode.update"]//, "passcode.read"
    #else
    let tokensScopeArr = ["openid", "offline", "identities.read", "accounts.read"]
    #endif
    
    //identityEndPoint -> https://identity.tllms.com/api/
  //  let otpEndPoint  = "https://identity-staging.tllms.com/api/request_otp"
  //  let identityEndPoint = "https://identity-staging.tllms.com/api/identities/"
   
    
    override init() {
        super.init()
        let configPath = Bundle.main.path(forResource: "TLConfiguration", ofType: "plist")
        if let path = configPath {
            if let configurations =  NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject>{
                guard let tokenURlStr = configurations["tokenEndpoint"] as? String, let tokenURL = URL(string: tokenURlStr) else {
                    return
                }
                guard let autherisationEndpointStr = configurations["authorizationEndpoint"] as? String , let autherisationURL = URL(string: autherisationEndpointStr) else {
                    return
                }
                guard let clientID = configurations["clientID"] as? String else {
                    return
                }
                guard let redirectionURlStr = configurations["redirectionURL"] as? String, let redirectionURL = URL(string: redirectionURlStr) else {
                    return
                }
                
                if let identityBaseURLString = configurations["identityBaseURL"] as? String {
                    otpEndPoint = identityBaseURLString + "request_otp"
                    identityEndPoint = identityBaseURLString + "identities/"
                    passcodePolicyEndPoint = identityBaseURLString + "v2/passcode/policy"
                    resendPasscodeEndPoint = identityBaseURLString + "passcode/resend"
                    passcodeInitiateEndPoint = identityBaseURLString + "authenticate/initiate/passcode"
                    tokenInitiateEndPoint = identityBaseURLString + "authenticate/initiate/token"
                    updatePasscodeEndPoint = identityBaseURLString + "passcode/update"
                    validateOtpEndPoint = identityBaseURLString + "v2/validate_otp"
                }
                
                self.idservice =  IDService(kTokenEndPoint:tokenURL, kAuthorizationEndpoint:autherisationURL, kClientID: clientID, kRedirectionURL: redirectionURL)
            }
            
        }
    }
    
  @objc public func handle(url:URL){
        self.idservice?.handle(url: url)
    }
    
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
}

