import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class MockNetworkInterceptor extends Interceptor {
  final SharedPreferences prefs;

  MockNetworkInterceptor({required this.prefs});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final latencyEnabled =
        prefs.getBool(AppConstants.simulatedLatencyKey) ?? true;
    final force503 = prefs.getBool(AppConstants.forceHttp503Key) ?? false;

    if (latencyEnabled) {
      final random = Random();
      final delay = 400 + random.nextInt(450); // 400ms - 850ms
      await Future.delayed(Duration(milliseconds: delay));
    }

    if (force503) {
      // Simulated HTTP 503 Service Unavailable to test retry mechanisms
      handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 503,
            statusMessage: 'Simulated Recruiter Debug 503: Service Unavailable',
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }

    // Default mock response handler
    handler.next(options);
  }
}
