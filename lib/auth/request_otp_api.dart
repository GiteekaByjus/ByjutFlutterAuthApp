import 'package:byjus_flutter_auth_app/auth/error.dart';
import 'package:byjus_flutter_auth_app/auth/request_otp_reponse.dart';
import 'package:byjus_flutter_auth_app/auth/response.dart';
import 'package:byjus_network/api_services.dart';
import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:fimber/fimber.dart';

@injectable
class IdentityApiService {
  String baseUrl = "https://identity-staging.tllms.com/api/";
  final Dio _dio = Dio();

  Future<ApiResponse<RequestOTPResponse, Error>> getOTPNonce(
      {required String phone,
      required String type,
      String appClientId = "c76e833f-b924-4016-8f77-7b093cc52e88",
      String feature = "otp"}) async {
    try {
      _dio.interceptors.add(ChuckerDioInterceptor());
      Fimber.d("calling -getOTPNonce $phone , $type, $appClientId , $feature , ");
      var data = await _dio.post(
        "${baseUrl}request_otp",
        data : {
          "phone": phone,
          "type": type,
          "app_client_id": appClientId,
          "feature": feature
        },
      );
      Fimber.d("RequestOTPResponse test - ${data}");
      return ApiResponse.completed(RequestOTPResponse.fromJson(data.data));
    } catch (e, stacktrace) {
      Fimber.e("RequestOTPResponse stacktrace - ", stacktrace: stacktrace);
      const errorMessage = "error in request otp";
      return const ApiResponse.error(Error(message: errorMessage));
    }
  }
}
