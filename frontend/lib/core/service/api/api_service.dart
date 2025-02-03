import 'package:dio/dio.dart';
import 'package:flutter_application_2/core/service/api/end_points.dart';
import '../../../core/network/dio_interceptor.dart';

class ApiService {
  final Dio dio;

  ApiService() : dio = Dio(
    BaseOptions(
        baseUrl: EndPoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30)),
  ) {
    // dio.interceptors.add(TokenInterceptor(dio: dio));
  }

  Future get(String url, {Map<String, dynamic>? headers, queryParameters}) {
    final response = dio.get(url,
        queryParameters: queryParameters, options: Options(headers: headers));
    return response;
  }

  Future post(String url,
      {Map<String, dynamic>? headers, body, queryParameters}) {
    final response = dio.post(url,
        queryParameters: queryParameters,
        data: body,
        options: Options(headers: headers));
    return response;
  }

  Future delete(String url, {Map<String, dynamic>? headers, queryParameters}) {
    final response = dio.delete(url,
        queryParameters: queryParameters, options: Options(headers: headers));
    return response;
  }

  Future put(String url,
      {Map<String, dynamic>? headers, body, queryParameters}) {
    final response = dio.put(url,
        queryParameters: queryParameters,
        data: body,
        options: Options(headers: headers));
    return response;
  }

  Future patch(String url,
      {Map<String, dynamic>? headers, body, queryParameters}) {
    final response = dio.patch(url,
        queryParameters: queryParameters,
        data: body,
        options: Options(headers: headers));
    return response;
  }
}
