//
//  IDService.swift
//  AuthSDK
//
//  Created by Suhas K on 16/02/21.
//  Copyright © 2021 BYJUS. All rights reserved.
//

import Foundation
import AppAuth
import CommonCrypto

public class IDService :NSObject {
    private var authState: OIDAuthState?
    private var configuration : OIDServiceConfiguration?
    let clientID: String?
    let authorizationEndpoint : URL?
    let tokenEndpoint : URL?
    let redirectURI: URL?
   public var accesstoken : String?
   public var idToken : String?
   public var identityID : String?
   public var currentAuthorizationFlow: OIDExternalUserAgentSession?
    
    /*
     Designated initilaiser
     intialises the idervice pbject witg the config  created using given endpoints
     redirectURI - urlscheme to support redirection - scheme has to be set up in the client app to support this
     */
   public init(kTokenEndPoint: URL, kAuthorizationEndpoint : URL, kClientID:String, kRedirectionURL: URL){
        self.tokenEndpoint = kTokenEndPoint
        self.authorizationEndpoint = kAuthorizationEndpoint
        self.clientID = kClientID
        self.redirectURI = kRedirectionURL
        self.configuration = OIDServiceConfiguration(authorizationEndpoint: kAuthorizationEndpoint,
                                                     tokenEndpoint: kTokenEndPoint)
    }
    
    // MARK: - IDSERVICE METHODS
    /*
     responds with the otp for the mopbiolenumber
     */
   public func getOtp(url: String, params:Dictionary<String, String>, completion: @escaping ([String: Any]?, Error?, Dictionary<String, AnyObject>?) -> Void){
//        let params = ["phone":phoneNumber] as Dictionary<String, String>
       self.sendRequest(url, parameters: params) { [weak self] responseObject, error, responseHeaders  in
            guard let responseObject = responseObject, error == nil else {
                print(error ?? "Unknown error")
                completion(nil, error, nil)
                return
            }
           completion(responseObject, nil, responseHeaders)
        }
    }
    
    /*
      params must contain
      values for keys -
     "verification[method]", -  method of verification for ios always "otp"
     "verification[otp]",    -  otp value
     "verfication[phone]",   - phone numeber
     "verfication[nonce]"    - nonce from the getotp response
     nonce - random string
     example -
     ["verification[method]":"otp",
      "verification[otp]":"1233",
      "verfication[phone]":"+91-6547891233",
      "verfication[nonce]":"b1d6a368-7e2a-4e2e-899e-f2b3bda71478","nonce":randomString]
     */
    public func getTokens(scope : [String], viewController : UIViewController, param:[String:String], completion: @escaping ([String: Any]?, Error?) -> Void) {
        let request = OIDAuthorizationRequest(configuration: self.configuration!,
                                              clientId: self.clientID!,
                                              clientSecret: nil,//"-wVyDW76RANjN_gBO7H_iFygCl",
                                              scopes: scope,
                                              redirectURL: self.redirectURI!,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: param)
        
        print("Initiating authorization request with scope: \(request.scope ?? "nil")")
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.currentAuthorizationFlow =
        OIDAuthState.authState(byPresenting: request,
                               presenting: viewController,
                               prefersEphemeralSession: true) { authState, error in
            if let authState = authState {
                self.authState = authState
                let refreshToken = self.authState?.refreshToken
                TLUserDefaults.sharedManager.setLastRefreshToken(token: refreshToken ?? "")
                print("Got authorization tokens. Access token: " +
                      "\(authState.lastTokenResponse?.accessToken ?? "nil")")
                self.accesstoken = authState.lastTokenResponse?.accessToken
                self.idToken = authState.lastTokenResponse?.idToken!
                do {
                    let oidctokenPayload = try JWTParser.decode(jwtToken:self.idToken!)
                    print(oidctokenPayload)
                    let sub = oidctokenPayload["sub"] as! String
                    self.identityID = sub.replacingOccurrences(of: "urn:identity:", with: "")
                    completion(oidctokenPayload,nil)
                } catch {
                    completion(nil,error)
                }
            } else {
                print("Authorization error: \(error?.localizedDescription ?? "Unknown error")")
                self.authState = nil
                completion(nil,error)
            }
        }
    }
    
    /*
     refresh the tokens frequently - replaces accestoken with new token if it is expired else resends the same
     */
    public func refreshTokens(refreshtoken: String, completion: @escaping (String?,String?, Error?)-> Void) {
       let request = OIDTokenRequest(
           configuration: self.configuration!,
           grantType: OIDGrantTypeRefreshToken,
           authorizationCode: nil,
           redirectURL: nil,
           clientID: self.clientID!,
           clientSecret: nil,
           scope: nil,
           refreshToken: refreshtoken,
           codeVerifier: nil,
           additionalParameters: nil)

        OIDAuthorizationService.perform(request) { tokenResponse, error in
            if error == nil {
                print(tokenResponse)
                TLUserDefaults.sharedManager.setLastRefreshToken(token: tokenResponse?.refreshToken ?? "")
                TLUserDefaults.sharedManager.setLastAccessToken(token: tokenResponse?.accessToken ?? "")
                TLUserDefaults.sharedManager.setLastIdToken(token: tokenResponse?.idToken ?? "")
                completion(tokenResponse?.accessToken ?? "", tokenResponse?.idToken ?? "", nil)
            } else {
                completion(nil, nil, error)
            }
        }
        
//        self.authState?.performAction(freshTokens: { accessToken, idToken, error in
//            completion(accessToken,idToken,error)
//        })
    }
    
    /*
     fetch the accounts associated with thge user
     */
   public func getAccounts(url: String, accessToken: String, identityID:String, completion: @escaping ([String: Any]?, Error?) -> Void){
        var url = url
        url.append(identityID)
        let params = ["access_token":accessToken,"identity_id":identityID] as Dictionary<String, String>
       self.sendRequest(url, parameters: params) { [weak self] responseObject, error, responseHeaders  in
            guard let responseObject = responseObject, error == nil else {
                print(error ?? "Unknown error")
                completion(nil, error)
                return
            }
            completion(responseObject, nil)
        }
    }
    
    /*
     Call this to handle redirect urls from app/sean delegate
     */
   public func handle(url:URL){
        if let authorizationFlow = self.currentAuthorizationFlow,
            authorizationFlow.resumeExternalUserAgentFlow(with: url) {
            self.currentAuthorizationFlow = nil
        }
    }
    
    public func sendRequest(_ url: String, parameters: [String: String], completion: @escaping ([String: Any]?, Error?, Dictionary<String, AnyObject>?) -> Void) {
        var components = URLComponents(string: url)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let request = URLRequest(url: components.url!)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                            // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                error == nil else {                           // was there no error, otherwise ...
                    completion(nil, error, nil)
                    return
            }
            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            completion(responseObject, nil, response.allHeaderFields as? Dictionary<String, AnyObject>)
        }
        task.resume()
    }
}
