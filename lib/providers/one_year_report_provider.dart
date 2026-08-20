import 'package:flutter/foundation.dart';

import '../Model/one_year_report_model.dart';
import '../services/one_year_report_api_service.dart';

class OneYearReportProvider extends ChangeNotifier {
  final OneYearReportApiService _apiService =
  OneYearReportApiService();

  bool isLoading = false;
  bool isLatestLoading = false;
  bool isViewLoading = false;

  String? errorMessage;

  List<OneYearReportListItem> reports = [];

  Map<String, dynamic>? latestReport;
  Map<String, dynamic>? selectedReport;

  // ============================================================
  // GET ALL REPORTS
  // ============================================================

  Future<void> fetchAllReports() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response =
      await _apiService.getAllReports();

      final List<dynamic> data =
          response["data"] ?? [];

      reports = data
          .map(
            (item) => OneYearReportListItem.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // GET LATEST REPORT
  // ============================================================

  Future<void> fetchLatestReport() async {
    try {
      isLatestLoading = true;
      errorMessage = null;
      notifyListeners();

      final response =
      await _apiService.getLatestReport();

      latestReport =
      Map<String, dynamic>.from(
        response["data"] ?? {},
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLatestLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // GET REPORT BY ID
  // ============================================================

  Future<void> fetchReportById(int id) async {
    try {
      isViewLoading = true;
      errorMessage = null;
      selectedReport = null;
      notifyListeners();

      final response =
      await _apiService.getReportById(id);

      debugPrint("========== REPORT BY ID ==========");
      debugPrint("REPORT ID => $id");
      debugPrint("API RESPONSE => $response");

      final data = response["data"];

      if (data == null || data is! Map) {
        throw Exception(
          "Invalid report data received from server",
        );
      }

      selectedReport =
      Map<String, dynamic>.from(data);

      debugPrint(
        "SELECTED REPORT => $selectedReport",
      );

    } catch (e) {
      debugPrint(
        "FETCH REPORT BY ID ERROR => $e",
      );

      errorMessage = e.toString();
    } finally {
      isViewLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedReport() {
    selectedReport = null;
    notifyListeners();
  }
}