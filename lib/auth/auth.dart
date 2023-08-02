import 'dart:io';

import 'package:byjus_flutter_auth_app/auth/request_otp_api.dart';
import 'package:byjus_flutter_auth_app/auth/request_otp_reponse.dart';
import 'package:byjus_flutter_auth_app/auth/response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:byjus_flutter_auth_app/auth/error.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:uuid/uuid.dart';

void main() {
  Fimber.plantTree(DebugTree());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final IdentityApiService _apiService = IdentityApiService();
  final TextEditingController _authorizationCodeTextController =
      TextEditingController();
  String nonce = "";
  String phoneNumber = "+91-3442233555";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
            ),
            body: SafeArea(
                child: SingleChildScrollView(
                    child: Column(children: <Widget>[
              const SizedBox(height: 8),
              ElevatedButton(
                child: const Text('Request OTP'),
                onPressed: () => _performSignInViaAuth(),
              ),
              const SizedBox(height: 8),
              const Text('OTP code'),
              const SizedBox(height: 8),
              TextField(
                controller: _authorizationCodeTextController,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                child: const Text('Sign in OAuth'),
                onPressed: () => _verifyOTP(
                    phoneNumber, nonce, _authorizationCodeTextController.text),
              )
            ])))));
  }

  _performSignInViaAuth() async {
    ApiResponse<RequestOTPResponse, Error> response =
        await _apiService.getOTPNonce(phone: phoneNumber, type: "otp");
    Fimber.d("RequestOTPResponse - $response");
    if (response.success && response.data != null) {
      Fimber.d("RequestOTPResponse Success - ${response.data?.nonce}");
      nonce = response.data?.nonce ?? '';
    } else {
      Fimber.d("RequestOTPResponse Error - ${response.error?.message}");
    }
  }

  // https://hydra-auth-staging.tllms.com/oauth2/auth
  // // https://hydra-auth-staging.tllms.com/oauth2/token
  //
  // // For a list of client IDs, go to https://demo.duendesoftware.com
  final String _clientId = '527c5e34-c78e-49f9-be8b-8a34e5db5ddf';
  final String _redirectUrl = 'com.byjus.auth:/oauth2_callback';

  // final String _issuer = 'https://demo.duendesoftware.com';
  final String _discoveryUrl = '';

  // final String _postLogoutRedirectUrl = 'com.duendesoftware.demo:/';
  final List<String> _scopes = <String>[
    'openid',
    'offline',
    'identities.read',
    'accounts.read',
  ];

  final AuthorizationServiceConfiguration _serviceConfiguration =
      const AuthorizationServiceConfiguration(
    authorizationEndpoint: 'https://hydra-auth-staging.tllms.com/oauth2/auth',
    tokenEndpoint: 'https://hydra-auth-staging.tllms.com/oauth2/token',
  );

// val CONFIG = AuthorizationServiceConfiguration(
  //     Uri.parse(AUTH_ENDPOINT),
  //     Uri.parse(TOKEN_ENDPOINT)
  // )
  // const val REDIRECT_URI = "com.byjus.auth:/oauth2_callback"

  // AuthorizationRequest.Builder(
  // SDKConstants.OAuth.CONFIG,
  // clientId,
  // ResponseTypeValues.CODE,
  // Uri.parse(SDKConstants.OAuth.REDIRECT_URI)
  // ).setScope(
  // tokenScope
  // )

  // authRequestBuilder.setAdditionalParameters(
  // mapOf(
  // SDKConstants.OAuth.Params.NONCE to UUID.randomUUID().toString(),
  // SDKConstants.OAuth.Params.Verification.METHOD to SDKConstants.OAuth.Params.OTP,
  // SDKConstants.OAuth.Params.Verification.NONCE to nonce,
  // SDKConstants.OAuth.Params.Verification.PHONE to mobileNumber,
  // SDKConstants.OAuth.Params.Verification.OTP to otp,
  // SDKConstants.OAuth.Params.API_VERSION to "2"
  // )
  // )
  //
  // _state.value = AuthRequestFetched(authRequestBuilder.build())
  // wvOAuth.loadUrl(authRequest.toUri().toString())

  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  Future<void> _verifyOTP(String phoneNumber, String nonce, String otp) async {
    var uuid = const Uuid().v1();
    Fimber.d(
        "_verifyOTP = phoneNumber - $phoneNumber, nonce - $nonce, otp - $otp, uuid - $uuid");
    AuthorizationTokenRequest authorizationRequest = AuthorizationTokenRequest(
        _clientId, _redirectUrl,
        serviceConfiguration: _serviceConfiguration,
        scopes: _scopes,
        additionalParameters: {
          "nonce": uuid ,
          "verification[method]": "otp",
          "verification[nonce]": nonce,
          "verification[phone]": phoneNumber,
          "verification[otp]": otp,
          "api_version": "2"
        });
    final AuthorizationTokenResponse? response =
        await _appAuth.authorizeAndExchangeCode(authorizationRequest);
    _processAuthResponse(response);
  }

  void _processAuthResponse(AuthorizationTokenResponse? response) {
    Fimber.d("_processAuthResponse = $response");
    Fimber.d("Access Token Expiration DateTime - ${response?.accessTokenExpirationDateTime}");
    Fimber.d("Access token -  ${response?.accessToken}, "
        "Refresh token - ${response?.refreshToken}, "
        "ID token - ${response?.idToken}, ");
  }
}
