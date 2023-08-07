import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fimber/fimber.dart';

String _nonceStatus = 'Unknown nonce value';
String _verifyOTPStatus = 'Unknown verify otp status.';
String _passcodePolicyStatus = 'Unknown Passcode Policy status.';
String _nonce = '';

void main() {
  Fimber.plantTree(DebugTree());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyApp> {
  static const platform = MethodChannel('com.byjus.auth/authapp');
  final TextEditingController _otpTextController = TextEditingController();
  final TextEditingController _phoneNumberTextController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextField(
                  controller: _phoneNumberTextController,
                ),
                ElevatedButton(
                  onPressed: () =>
                      _getPasscodePolicy(_phoneNumberTextController.text),
                  child: const Text('Get Passcode Policy  '),
                ),
                ElevatedButton(
                  onPressed: () => _getNonce(_phoneNumberTextController.text),
                  child: const Text('Request OTP'),
                ),
                const SizedBox(height: 8),
                Text(_nonceStatus),
                const SizedBox(height: 8),
                TextField(
                  controller: _otpTextController,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _verifyOTP(_phoneNumberTextController.text,
                      _nonce, _otpTextController.text),
                  child: const Text('Verify OTP'),
                ),
                const SizedBox(height: 8),
                Text(_verifyOTPStatus),
                const SizedBox(height: 8),
                Text(_passcodePolicyStatus),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOTP(String phoneNumber, String nonce, String otp) async {
    String verifyOTPStatus;
    final args = <String, dynamic>{
      'mobile_no': phoneNumber,
      'nonce': nonce,
      'otp': otp,
    };
    try {
      final String result = await platform.invokeMethod('verifyOTP', args);
      Fimber.d("_verifyOTP result - $result");
      verifyOTPStatus = "Verify OTP Success \n ID token = $result";
    } on PlatformException catch (e) {
      verifyOTPStatus = "Failed OTP verification: '${e.message}'.";
      Fimber.d("_verifyOTP error - $_verifyOTPStatus");
    }
    setState(() {
      _verifyOTPStatus = verifyOTPStatus;
    });
  }

  Future<void> _getNonce(String phoneNumber) async {
    String nonce;
    try {
      final args = <String, dynamic>{
        'mobile_no': phoneNumber,
      };
      final String result = await platform.invokeMethod('requestOTP', args);
      nonce = 'nonce - $result.';
      _nonce = result;
    } on PlatformException catch (e) {
      nonce = "Failed to get nonce level: '${e.message}'.";
    }

    setState(() {
      _nonceStatus = nonce;
    });
  }

  Future<void> _getPasscodePolicy(String phoneNumber) async {
    String passcodePolicy;
    try {
      final args = <String, dynamic>{
        'mobile_no': phoneNumber,
      };
      final String result = await platform.invokeMethod('passcodePolicy', args);
      print(result);
      passcodePolicy = result;
    } on PlatformException catch (e) {
      passcodePolicy = e.message ?? "Failed to get Passcode policy ";
    }

    setState(() {
      _passcodePolicyStatus = passcodePolicy;
    });
  }
}
