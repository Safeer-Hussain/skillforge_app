import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_network_interceptor.dart';

class DioClient {
  final Dio dio;

  DioClient({required SharedPreferences prefs})
    : dio = Dio(
        BaseOptions(
          baseUrl: 'https://api.skillforge.internal/v1',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    dio.interceptors.add(MockNetworkInterceptor(prefs: prefs));
  }
}
