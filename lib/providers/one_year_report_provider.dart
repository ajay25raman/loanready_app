import 'dart:async';
import 'package:flutter/foundation.dart';

import '../Model/one_year_report_model.dart';
import '../services/one_year_report_api_service.dart';

class OneYearReportProvider extends ChangeNotifier {
  final OneYearReportApiService _apiService =
  OneYearReportApiService();

  // ============================================================
  // LOADING STATES
  // ============================================================

  bool isLoading = false;
  bool isLatestLoading = false;
  bool isViewLoading = false;

  // ============================================================
  // ERROR
  // ============================================================

  String? errorMessage;

  // ============================================================
  // DATA
  // ============================================================

  List<OneYearReportListItem> reports = [];

  Map<String, dynamic>? latestReport;
  Map<String, dynamic>? selectedReport;

  // ============================================================
  // GET ALL REPORTS  (FIXED)
  // ============================================================

  Future<void> fetchAllReports() async {
    // Prevent duplicate API calls
    if (isLoading) return;

    // Sirf pehli baar full loader dikhao
    final bool isFirstLoad = reports.isEmpty;

    if (isFirstLoad) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      debugPrint(
        '========== FETCH ALL REPORTS START ==========',
      );

      Map<String, dynamic>? response;

      // 1 retry on timeout / network error
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          response = await _apiService
              .getAllReports()
              .timeout(const Duration(seconds: 12));
          break;
        } on TimeoutException {
          debugPrint(
            'FETCH ALL REPORTS TIMEOUT (attempt $attempt)',
          );
          if (attempt == 2) rethrow;
          await Future.delayed(const Duration(milliseconds: 700));
        } catch (e) {
          debugPrint(
            'FETCH ALL REPORTS ERROR (attempt $attempt) => $e',
          );
          if (attempt == 2) rethrow;
          await Future.delayed(const Duration(milliseconds: 700));
        }
      }

      debugPrint('GET ALL REPORTS RESPONSE => $response');

      if (response == null || response["success"] != true) {
        // Sirf tab error dikhao jab pehle se data nahi hai
        if (isFirstLoad) {
          errorMessage = _getSafeErrorMessage(
            response?["message"],
          );
        }
        return;
      }

      final rawData = response["data"];

      if (rawData == null) {
        reports = [];
        return;
      }

      if (rawData is! List) {
        if (isFirstLoad) {
          errorMessage = 'Unable to load financial reports.';
        }
        return;
      }

      reports = rawData
          .map(
            (item) => OneYearReportListItem.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();

      errorMessage = null;

      debugPrint('REPORT COUNT => ${reports.length}');
    } catch (e, stackTrace) {
      debugPrint('FETCH ALL REPORTS ERROR => $e');
      debugPrint('STACK TRACE => $stackTrace');

      // Sirf pehli load pe error dikhao
      if (isFirstLoad) {
        errorMessage = _getFriendlyErrorCode(e);
      }
    } finally {
      isLoading = false;
      notifyListeners();

      debugPrint(
        '========== FETCH ALL REPORTS END ==========',
      );
    }
  }

  // ============================================================
  // GET LATEST REPORT
  // ============================================================

  Future<void> fetchLatestReport() async {
    if (isLatestLoading) return;

    isLatestLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      debugPrint(
        '========== FETCH LATEST REPORT START ==========',
      );

      final response = await _apiService
          .getLatestReport()
          .timeout(const Duration(seconds: 12));

      debugPrint('LATEST REPORT RESPONSE => $response');

      if (response["success"] != true) {
        errorMessage = _getSafeErrorMessage(response["message"]);
        return;
      }

      final data = response["data"];

      if (data == null || data is! Map) {
        latestReport = null;
        return;
      }

      latestReport = Map<String, dynamic>.from(data);
    } catch (e, stackTrace) {
      debugPrint('FETCH LATEST REPORT ERROR => $e');
      debugPrint('STACK TRACE => $stackTrace');
      errorMessage = _getFriendlyErrorCode(e);
    } finally {
      isLatestLoading = false;
      notifyListeners();

      debugPrint(
        '========== FETCH LATEST REPORT END ==========',
      );
    }
  }

  // ============================================================
  // GET REPORT BY ID
  // ============================================================

  Future<void> fetchReportById(int id) async {
    if (isViewLoading) return;

    isViewLoading = true;
    errorMessage = null;
    selectedReport = null;
    notifyListeners();

    try {
      debugPrint('========== REPORT BY ID ==========');
      debugPrint('REPORT ID => $id');

      final response = await _apiService
          .getReportById(id)
          .timeout(const Duration(seconds: 12));

      debugPrint('API RESPONSE => $response');

      if (response["success"] != true) {
        errorMessage = _getSafeErrorMessage(response["message"]);
        return;
      }

      final data = response["data"];

      if (data == null || data is! Map) {
        errorMessage = 'Unable to load report details.';
        return;
      }

      selectedReport = Map<String, dynamic>.from(data);

      debugPrint('SELECTED REPORT => $selectedReport');
    } catch (e, stackTrace) {
      debugPrint('FETCH REPORT BY ID ERROR => $e');
      debugPrint('STACK TRACE => $stackTrace');
      errorMessage = _getFriendlyErrorCode(e);
    } finally {
      isViewLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // FRIENDLY ERROR CODE
  // ============================================================

  String _getFriendlyErrorCode(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('no address associated with hostname') ||
        message.contains('network is unreachable') ||
        message.contains('connection refused') ||
        message.contains('connection reset') ||
        message.contains('connection closed') ||
        message.contains('clientexception')) {
      return 'NO_INTERNET';
    }

    if (message.contains('timeout') || message.contains('timed out')) {
      return 'REQUEST_TIMEOUT';
    }

    if (message.contains('401') ||
        message.contains('unauthorized') ||
        message.contains('token expired') ||
        message.contains('session expired')) {
      return 'SESSION_EXPIRED';
    }

    if (message.contains('500') ||
        message.contains('502') ||
        message.contains('503') ||
        message.contains('504')) {
      return 'SERVER_ERROR';
    }

    return 'UNABLE_TO_LOAD_REPORTS';
  }

  // ============================================================
  // SAFE API ERROR
  // ============================================================

  String _getSafeErrorMessage(dynamic message) {
    if (message == null) {
      return 'UNABLE_TO_LOAD_REPORTS';
    }

    final value = message.toString().toLowerCase();

    if (value.contains('socket') ||
        value.contains('network') ||
        value.contains('connection')) {
      return 'NO_INTERNET';
    }

    if (value.contains('401') ||
        value.contains('unauthorized') ||
        value.contains('session')) {
      return 'SESSION_EXPIRED';
    }

    if (value.contains('500') ||
        value.contains('502') ||
        value.contains('503') ||
        value.contains('504')) {
      return 'SERVER_ERROR';
    }

    if (value.contains('timeout')) {
      return 'REQUEST_TIMEOUT';
    }

    return 'UNABLE_TO_LOAD_REPORTS';
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clearSelectedReport() {
    selectedReport = null;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}