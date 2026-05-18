import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:walpy/app/core/network/error_response_modle.dart';

import 'api_const.dart';

class DioClient {
  DioClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConst.baseUrl,
        connectTimeout: ApiConst.connectTimeout,
        receiveTimeout: ApiConst.receiveTimeout,
        sendTimeout: ApiConst.sendTimeout,
        queryParameters: {"client_id": ApiConst.apiKey},
      ),
    );

    _dio.interceptors.addAll([
      PrettyDioLogger(requestHeader: true, requestBody: true),
    ]);
  }

  static final instance = DioClient._();
  late final Dio _dio;

  final _connectivity = Connectivity();

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();

    if (result == ConnectivityResult.none) return false;

    try {
      final lookup = await InternetAddress.lookup('google.com');
      return lookup.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// async get method
  Future<dynamic> performGet({
    required String url,
    required Map<String, dynamic> params,
  }) async {
    if(!await isOnline()){
      throw "No internet connection";
    }
    try{
      final response = await _dio.get(url,queryParameters: params);
      return response.data;
    }on DioException catch(e){
      if (e.type == DioExceptionType.badResponse && e.response?.data != null) {
        final serverError = ErrorResponse.fromJson(e.response!.data);
        throw serverError.errors?.first ?? _handleError(e);
      }
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'Network error. Please try again.';
    }
  }
}
