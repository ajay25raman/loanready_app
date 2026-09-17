import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OneYearTradingProvider extends ChangeNotifier {
  final Dio _dio = Dio();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _resultData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get resultData => _resultData;

  // ============================================================
  // GENERATE REPORT
  // ============================================================

  Future<Map<String, dynamic>?> generateReport({
    required double sales,
    required double commissionReceived,
    required double cashInHand,
    required double cashInBank,
    required double landAndBuilding,
  }) async {
    if (_isLoading) return null;

    _isLoading = true;
    _errorMessage = null;
    _resultData = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        _errorMessage = 'Session expired. Please login again.';
        return null;
      }

      final payload = <String, dynamic>{
        'sales': sales,
        'commissionReceived': commissionReceived,
        'cashInHand': cashInHand,
        'cashInBank': cashInBank,
        'landAndBuilding': landAndBuilding,
        'g2': 20,
        'g3': 25,
      };

      debugPrint('GENERATE REPORT PAYLOAD => $payload');

      Response? response;

      // 1 retry on timeout
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          response = await _dio
              .post(
            'https://loan.edugaondev.com/api/v1/trade/one-year',
            data: payload,
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              sendTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              connectTimeout: const Duration(seconds: 10),
            ),
          )
              .timeout(const Duration(seconds: 20));
          break;
        } on DioException catch (e) {
          if (attempt == 2) rethrow;

          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            await Future.delayed(const Duration(milliseconds: 700));
            continue;
          }
          rethrow;
        } on TimeoutException {
          if (attempt == 2) rethrow;
          await Future.delayed(const Duration(milliseconds: 700));
        }
      }

      if (response == null) {
        _errorMessage = 'Unable to generate report. Please try again.';
        return null;
      }

      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['success'] == true) {
        final result = Map<String, dynamic>.from(response.data);
        _resultData = result;
        debugPrint('FINAL REPORT RESULT => $result');
        return result;
      }

      String message = 'Failed to generate report.';
      if (response.data is Map) {
        message =
            response.data['message']?.toString() ?? 'Failed to generate report.';
      }
      _errorMessage = message;
      return null;
    } on DioException catch (e) {
      debugPrint('GENERATE REPORT DIO ERROR => $e');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        _errorMessage =
        'Server is taking too long to respond.\nPlease try again.';
      } else if (e.type == DioExceptionType.connectionError ||
          e.error.toString().contains('SocketException')) {
        _errorMessage =
        'No Internet Connection.\nPlease check your internet and try again.';
      } else if (e.response?.statusCode == 401) {
        _errorMessage = 'Your session has expired.\nPlease login again.';
      } else if (e.response?.data is Map) {
        final data = Map<String, dynamic>.from(e.response!.data);
        _errorMessage =
            data['message']?.toString() ?? 'Failed to generate report.';
      } else {
        _errorMessage = 'Unable to generate report.';
      }
      return null;
    } catch (e) {
      debugPrint('GENERATE REPORT ERROR => $e');
      _errorMessage = 'Unable to generate report. Please try again.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearResult() {
    _resultData = null;
    notifyListeners();
  }
}