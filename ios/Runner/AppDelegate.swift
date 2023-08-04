import UIKit
import Flutter



@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    
    @objc var idServiceManager : TNLIDServiceManager?
        
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            
            let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
            let batteryChannel = FlutterMethodChannel(name: "com.byjus.auth/authapp",
                                                      binaryMessenger: controller.binaryMessenger)
            batteryChannel.setMethodCallHandler({
                [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                guard let uSelf = self else { return }
                // This method is invoked on the UI thread.
                switch call.method {
                case "requestOTP":
                    let data = call.arguments as? [String: String]
                    let mobile = data?["mobile_no"] ?? ""
                    print("mobile - " + mobile)
                    uSelf.getNonce(mobile: mobile, result: result)
                    break
                case "verifyOTP":
                    let data = call.arguments as? [String: String]
                    let mobile = data?["mobile_no"] ?? ""
                    let nonce = data?["nonce"] ?? ""
                    let otp = data?["otp"] ?? ""

                    print("mobile - " + mobile)
                    uSelf.verifyOTP(completePhoneNumber: mobile, currentOtpValue: otp, nonceString: nonce, result: result)
                    break

                default:
                    result(FlutterMethodNotImplemented)
                    break
                }
            })
            
            GeneratedPluginRegistrant.register(with: self)
            idServiceManager = TNLIDServiceManager()
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
    
    private func getNonce(mobile :String, result: @escaping FlutterResult) {
        
        self.requestLoginOTP(mobileNumber:mobile) { [weak self](status, response ,errorMessage) in
            if (errorMessage != nil) {
                DispatchQueue.main.async{
                    result(FlutterError(code: "UNAVAILABLE - iOS",
                                        message: errorMessage ?? "OTP request error",
                                        details: nil))
                    
                }
            }
            else{
                DispatchQueue.main.async{
                    result(response ?? "")
                }
            }
        }
        
    }
    
    //    oauthClientId = "527c5e34-c78e-49f9-be8b-8a34e5db5ddf",
    //    appClientId = "c76e833f-b924-4016-8f77-7b093cc52e88",
    
    func verifyOTP(completePhoneNumber : String, currentOtpValue : String, nonceString:String,  result: @escaping FlutterResult) {
        let startDate = Date()
        if let idServiceManager = idServiceManager {
            
            let params :  [String : String] = ["verification[method]":"otp",
                                               "verification[phone]":completePhoneNumber,
                                               "verification[otp]": currentOtpValue,
                                               "verification[nonce]":nonceString ?? "",
                                               "api_version" :API_VERSION]
            
            idServiceManager.idservice?.getTokens(scope: idServiceManager.tokensScopeArr, viewController: self.window.rootViewController!, param: params) { [weak self] response, error in
                let executionTime = Date().timeIntervalSince(startDate)
                guard let responseDict = response, error == nil else {
                    let errorObj = error as NSError?
                    let userInfoDict = errorObj?.userInfo as? [String : Any]
                    let errorResponseDict = userInfoDict?["OIDOAuthErrorResponseErrorKey"] as? [String : Any]
                    
                    if let errorHintCode = errorResponseDict?["error_hint"] as? String {
                        let errorTitleMsg = errorResponseDict?["error"] as? String
                        let errorDescriptionMsg = errorResponseDict?["error_description"] as? String
                        var errorDesc = errorDescriptionMsg
                        let encodedDict =  errorDescriptionMsg?.base64Decoded()
                        var coolOffTimeStamp = ""
                        if let dict = encodedDict?.toJSON() as? [String:Any] {
                            errorDesc = dict["errorDesc"] as? String
                            coolOffTimeStamp = dict["rateReset"] as? String ?? ""
                        }
                        
                        if errorHintCode == RATE_LIMIT_EXCEEEDED {
                            DispatchQueue.main.async {
                                let timeStampInteger = Int(coolOffTimeStamp)
                                let date = Date(timeIntervalSince1970: TimeInterval(truncating: NSNumber(value: timeStampInteger ?? 0)))
                                let remainingMinutes = date.minutes(from: Date())
                                if remainingMinutes > 1 {
                                    result(FlutterError(code: kMaxAttemptsExhausted,
                                                        message: "You have exceeded the maximum number of attempts. Try again after \(remainingMinutes) minutes",
                                                        details: nil))
                                    
                                    //                                    self?.showErrorAlert(title: kMaxAttemptsExhausted, message: "You have exceeded the maximum number of attempts. Try again after \(remainingMinutes) minutes")
                                } else if remainingMinutes == 1 {
                                    result(FlutterError(code: kMaxAttemptsExhausted,
                                                        message: "You have exceeded the maximum number of attempts. Try again after \(remainingMinutes) minute",
                                                        details: nil))
                                    //                                    self?.showErrorAlert(title: kMaxAttemptsExhausted, message: "You have exceeded the maximum number of attempts. Try again after \(remainingMinutes) minute")
                                } else {
                                    result(FlutterError(code: kMaxAttemptsExhausted,
                                                        message: "You have exceeded the maximum number of attempts. Try again after some time",
                                                        details: nil))
                                    
                                    //                                    self?.showErrorAlert(title: kMaxAttemptsExhausted, message: "You have exceeded the maximum number of attempts. Try again after some time")
                                }
                            }
                        } else if errorHintCode == INVALID_CREDIENTIALS {
                            DispatchQueue.main.async {
                                result(FlutterError(code: "Invalid Credentials",
                                                    message: "Please enter correct OTP",
                                                    details: nil))
                                
                                
                                //                                self?.showErrorAlert(title: "Invalid Credentials", message: "Please enter correct OTP")
                                //                                if self?.viewControllerType == .updatePhoneNumber {
                                //                                    self?.viewModel.sendVerificationStatusEventForUpdate(status: "failure", errorMsg: "Please enter correct OTP", timeTaken: Int(executionTime))
                                //                                } else {
                                //                                    self?.viewModel.sendVerificationStatusEvent(status: "failure", errorMsg: "Please enter correct OTP", timeTaken: Int(executionTime))
                                //                                }
                            }
                        } else {
                            result(FlutterError(code: "Invalid Credentials",
                                                message: "Something when wrong",
                                                details: nil))
                            
                            
                            //                            self?.showErrorAlert(title: "", message: NSLocalizedString("kTechnicalDifficultyMessage", comment: ""))
                            //                            if self?.viewControllerType == .updatePhoneNumber {
                            //                                self?.viewModel.sendVerificationStatusEventForUpdate(status: "failure", errorMsg: NSLocalizedString("kTechnicalDifficultyMessage", comment: ""), timeTaken: Int(executionTime))
                            //                            } else {
                            //                                self?.viewModel.sendVerificationStatusEvent(status: "failure", errorMsg: NSLocalizedString("kTechnicalDifficultyMessage", comment: ""), timeTaken: Int(executionTime))
                            //                            }
                        }
                    }
                    if errorObj?.code == -2 {
                        DispatchQueue.main.async{
                            result(FlutterError(code: "Invalid Credentials",
                                                message:"Please enter correct OTP",
                                                details: nil))
                            
                            //                            self?.showErrorAlert(title: "Invalid Credentials", message: "Please enter correct OTP")
                            //                            if self?.viewControllerType == .updatePhoneNumber {
                            //                                self?.viewModel.sendVerificationStatusEventForUpdate(status: "failure", errorMsg: "Please enter correct OTP", timeTaken: Int(executionTime))
                            //                            } else {
                            //                                self?.viewModel.sendVerificationStatusEvent(status: "failure", errorMsg: "Please enter correct OTP", timeTaken: Int(executionTime))
                            //                            }
                        }
                    }
                    else if  errorObj?.code == -15 {
                        DispatchQueue.main.async{
                            result(FlutterError(code: "Error Code : \(errorObj?.code ?? 0)",
                                                message:"Token Validation Failed",
                                                details: nil))
                            
                            //                            self?.showErrorAlert(title: "Error Code : \(errorObj?.code ?? 0)", message: "Token Validation Failed")
                            //                            if self?.viewControllerType == .updatePhoneNumber {
                            //                                self?.viewModel.sendVerificationStatusEventForUpdate(status: "failure", errorMsg: "Token Validation Failed", timeTaken: Int(executionTime))
                            //                            } else {
                            //                                self?.viewModel.sendVerificationStatusEvent(status: "failure", errorMsg: "Token Validation Failed", timeTaken: Int(executionTime))
                            //                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async{
                            DispatchQueue.main.async{
                                result(FlutterError(code: "Error Code : \(errorObj?.code ?? 0)",
                                                    message:"Something when wrong",
                                                    details: nil))
                                
                                
                                //                            self?.showErrorAlert(title: "Error Code : \(errorObj?.code ?? 0)", message: NSLocalizedString("kTechnicalDifficultyMessage", comment: ""))
                                //                            if self?.viewControllerType == .updatePhoneNumber {
                                //                                self?.viewModel.sendVerificationStatusEventForUpdate(status: "failure", errorMsg: NSLocalizedString("kTechnicalDifficultyMessage", comment: ""), timeTaken: Int(executionTime))
                                //                            } else {
                                //                                self?.viewModel.sendVerificationStatusEvent(status: "failure", errorMsg: NSLocalizedString("kTechnicalDifficultyMessage", comment: ""), timeTaken: Int(executionTime))
                                //                            }
                            }
                        }
                    }
                    print(error ?? "Get Tokens Failure")
                    return
                }
                print("Get Tokens Success responseDict == \(responseDict)")
                result( idServiceManager.idservice?.idToken ?? "")
                TLUserDefaults.sharedManager.setLastAccessToken(token: idServiceManager.idservice?.accesstoken ?? "")
                TLUserDefaults.sharedManager.setLastIdToken(token: idServiceManager.idservice?.idToken ?? "")
                TLUserDefaults.sharedManager.setLastIdentityId(identityId: idServiceManager.idservice?.identityID ?? "")
                
            }
        }
    }
    
    
    func requestLoginOTP(mobileNumber: String?, completion: @escaping(Bool, String?, String?) -> Void) {
        
        //        let isdCode = country == nil ? "+91" : country!.isdCode
        //        let completePhoneNumber = "\(isdCode)-\(mobileNumber ?? "")"
        //
        if let idServiceManager = idServiceManager {
            let params = ["phone": mobileNumber ?? "", "app_client_id": "1"] as Dictionary<String, String>
            print("otpEndPoint" + idServiceManager.otpEndPoint)
            idServiceManager.idservice?.getOtp(url: idServiceManager.otpEndPoint, params:params, completion: { [weak self] responseDict, error, responseHeaders in
                guard let responseDict = responseDict, error == nil else {
                    print(error ?? "Get OTP Failure")
                    return
                }
                
                //Get OTP Success
                print("Get OTP Success responseDict == \(responseDict)")
                
                let nonceStr = responseDict["nonce"] as? String ?? ""
                
                completion(true,nonceStr,nil)
                
            })
            
        } else {
        }
    }
}
