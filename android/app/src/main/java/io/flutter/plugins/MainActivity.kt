package io.flutter.plugins

import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import com.byjus.authlib.AuthSDK
import com.byjus.authlib.data.model.AppUserDeviceInfo
import com.byjus.authlib.data.model.LoginResult
import com.byjus.authlib.data.model.PasscodePolicyInfo
import com.byjus.authlib.util.SDKConstants
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.byjus.auth/authapp"
    private val AUTHSDK_ERROR_CODE = "AuthSdk:Error"
    private val LOG_TAG = "AuthSdk:LOG"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        AuthSDK.init(
            applicationContext = applicationContext,
            oauthClientId = "527c5e34-c78e-49f9-be8b-8a34e5db5ddf",
            appClientId = "c76e833f-b924-4016-8f77-7b093cc52e88",
            isProd = false,
            additionalTokenScopes = "accounts.update identities.update identities.delete profiles.delete passcode.update",
            appUserDeviceInfo = AppUserDeviceInfo(
                appVersion = "1",
                deviceOSVersion = "11",
                userId = "1234",
                cohortId = "12",
                appId = "1",
                platform = "android",
                phoneNo = "+91-1343324234",
                appClientId = "c76e833f-b924-4016-8f77-7b093cc52e88"
            )
        )

        MethodChannel(
            flutterEngine.dartExecutor, CHANNEL
        ).setMethodCallHandler { call, result: MethodChannel.Result ->
            when (call.method) {
                "requestOTP" -> {
                    getNonceForRequestOTP(call.arguments, result)
                }

                "verifyOTP" -> {
                    verifyOTP(call.arguments, result)
                }

                "passcodePolicy" -> {
                    getPasscodePolicy(call.arguments, result)
                }
            }
        }
    }

    private fun getPasscodePolicy(
        arguments: Any, result: MethodChannel.Result
    ) {
        val args = arguments as? Map<*, *>
        val mobileNo = args?.get("mobile_no") as? String ?: ""
        AuthSDK.checkPasscodePolicy(
            // "phone", "token"
            identifier = "phone", value = mobileNo
        ) { passcodePolicyInfo: PasscodePolicyInfo?, exception: Exception? ->
            if (exception != null) {
                Log.e(LOG_TAG, "PasscodePolicy", exception)
                result.error(
                    AUTHSDK_ERROR_CODE, exception.message ?: "OTP verifcation error", null
                )
            } else {
                Log.e(LOG_TAG, "PasscodePolicy Success -- $passcodePolicyInfo")
                result.success(passcodePolicyInfo?.objectToString())
            }
        }
    }

    private fun verifyOTP(
        argus: Any, result: MethodChannel.Result
    ) {
        val args = argus as? Map<*, *>
        val mobileNo = args?.get("mobile_no") as? String ?: ""
        val nonce = args?.get("nonce") as? String ?: ""
        val otp = args?.get("otp") as? String ?: ""


        Log.d(LOG_TAG, "mobileNo - $mobileNo , nonce - $nonce , otp - $otp")

        AuthSDK.loginToIdentity(
            this, nonce, otp, mobileNo
        ) { idToken: LoginResult?, exception: Exception? ->
            if (exception != null) {
                Log.e(LOG_TAG, "Test", exception)
                result.error(
                    AUTHSDK_ERROR_CODE, exception.message ?: "OTP verifcation error", null
                )
            } else {
                Log.e(LOG_TAG, "Test", exception)
                result.success("success idToken - $idToken ")
            }
        }
    }


    private fun getNonceForRequestOTP(arguments: Any, result: MethodChannel.Result) {
        val args = arguments as? Map<*, *>
        val mobileNo = args?.get("mobile_no") as? String ?: ""
        AuthSDK.requestOtp(mobileNumber = mobileNo,
            otpType = "sms",
            feature = "",
            callback = { nonce: String?, exception: Exception? ->
                if (exception != null) {
                    Log.e(LOG_TAG, "Test", exception)
                    result.error(
                        AUTHSDK_ERROR_CODE, exception.message ?: "OTP request error", null
                    )
                } else {
                    Log.e(LOG_TAG, "Test", exception)
                    result.success(nonce)
                }

            })
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == SDKConstants.RequestCodes.REQUEST_CODE_LOGIN) {
            AuthSDK.handleResult(requestCode, resultCode, data)
        }
    }

    //transform a java object to json
    fun Any.objectToString(): String {
        val gson = Gson();
        return  gson.toJson(this).toString()
    }


}