package io.flutter.plugins

import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import com.byjus.authlib.AuthSDK
import com.byjus.authlib.data.model.AppUserDeviceInfo
import com.byjus.authlib.util.SDKConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.byjus.auth/authapp"

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

        MethodChannel(flutterEngine.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "requestOTP") {
                val args = call.arguments as? Map<*, *>
                val mobileNo = args?.get("mobile_no") as? String
                getNonceForRequestOTP(mobileNo ?: "") { nonce: String?, exception: Exception? ->
                    if (exception != null) {
                        Log.e("AuthSDK", "Test", exception)
                        result.error(
                            "UNAVAILABLE - Android", exception.message ?: "OTP request error", null
                        )
                    } else {
                        Log.e("AuthSDK", "Test", exception)
                        result.success(nonce)
                    }

                }
            } else if (call.method == "verifyOTP") {
                val args = call.arguments as? Map<*, *>
                val mobileNo = args?.get("mobile_no") as? String
                val nonce = args?.get("nonce") as? String
                val otp = args?.get("otp") as? String
                verifyOTP(
                    mobileNo ?: "", nonce ?: "", otp ?: ""
                ) { idToken: String?, exception: Exception? ->
                    if (exception != null) {
                        Log.e("AuthSDK", "Test", exception)
                        result.error(
                            "UNAVAILABLE - Android",
                            exception.message ?: "OTP verifcation error",
                            null
                        )
                    } else {
                        Log.e("AuthSDK", "Test", exception)
                        result.success("success idToken - $idToken ")
                    }
                }
            }
        }
    }

    private fun verifyOTP(
        mobileNo: String, nonce: String, otp: String, callback: (String?, Exception?) -> Unit
    ) {
        Log.d("AuthSDK" , "mobileNo - $mobileNo , nonce - $nonce , otp - $otp")
        AuthSDK.loginToIdentity(
            this, nonce, otp, mobileNo
        ) { loginResult, exception ->
            if (exception != null) {
                callback.invoke(null, exception)
            } else {
                callback.invoke(loginResult?.idToken, null)

            }
        }

    }


    private fun getNonceForRequestOTP(mobileNo: String, callback: (String?, Exception?) -> Unit) {
        AuthSDK.requestOtp(
            mobileNumber = mobileNo, otpType = "sms", feature = "", callback = callback
        )
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == SDKConstants.RequestCodes.REQUEST_CODE_LOGIN) {
            AuthSDK.handleResult(requestCode, resultCode, data)
        }
    }

}