import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:loanready_app/Model/bussiness_details_model.dart';

import 'storage_service.dart';

class BusinessApiService {
  static const String baseUrl =
      'https://loan.edugaondev.com/api/v1';

  final StorageService _storageService =
  StorageService();

  Future<Map<String, dynamic>> saveBusinessDetails(
      BusinessDetailsModel business,
      ) async {
    final token =
    await _storageService.getToken();

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message':
        'Authentication token not found.',
      };
    }

    try {
      final url =
      Uri.parse('$baseUrl/business');

      final response = await http.post(
        url,

        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },

        body: jsonEncode(
          business.toJson(),
        ),
      );

      // ==========================================================
      // DEBUG
      // ==========================================================

      debugPrint(
        'BUSINESS API URL => $url',
      );

      debugPrint(
        'BUSINESS API STATUS => ${response.statusCode}',
      );

      debugPrint(
        'BUSINESS API CONTENT TYPE => '
            '${response.headers['content-type']}',
      );

      debugPrint(
        'BUSINESS API RESPONSE => ${response.body}',
      );

      // ==========================================================
      // EMPTY RESPONSE
      // ==========================================================

      if (response.body.trim().isEmpty) {
        return {
          'success': false,
          'message':
          'Server returned an empty response.',
        };
      }

      // ==========================================================
      // CHECK CONTENT TYPE
      // ==========================================================

      final contentType =
          response.headers['content-type'] ??
              '';

      if (!contentType
          .toLowerCase()
          .contains('application/json')) {
        final body = response.body.trim();

        // Cloudflare / HTML response
        if (body.startsWith('<!DOCTYPE') ||
            body.startsWith('<html') ||
            body.contains(
              'Just a moment',
            )) {
          return {
            'success': false,
            'message':
            'Server security check blocked the API request. '
                'Please check Cloudflare/API configuration.',
            'statusCode':
            response.statusCode,
            'isCloudflare': true,
          };
        }

        return {
          'success': false,
          'message':
          'Server returned an invalid response.',
          'statusCode':
          response.statusCode,
        };
      }

      // ==========================================================
      // JSON DECODE
      // ==========================================================

      Map<String, dynamic> data;

      try {
        final decoded =
        jsonDecode(response.body);

        if (decoded is! Map) {
          return {
            'success': false,
            'message':
            'Invalid JSON response from server.',
          };
        }

        data =
        Map<String, dynamic>.from(
          decoded,
        );
      } on FormatException catch (e) {
        debugPrint(
          'BUSINESS JSON ERROR => $e',
        );

        return {
          'success': false,
          'message':
          'Invalid response received from server.',
        };
      }

      // ==========================================================
      // SUCCESS
      // ==========================================================

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return {
          'success':
          data['success'] ?? true,
          'message':
          data['message']?.toString() ??
              'Business details saved successfully.',
          'data': data['data'],
        };
      }

      // ==========================================================
      // UNAUTHORIZED
      // ==========================================================

      if (response.statusCode == 401) {
        await _storageService.clearToken();

        return {
          'success': false,
          'message':
          data['message']?.toString() ??
              'Session expired. Please login again.',
          'isUnauthorized': true,
        };
      }

      // ==========================================================
      // SERVER / VALIDATION ERROR
      // ==========================================================

      return {
        'success': false,
        'message':
        data['message']?.toString() ??
            data['error']?.toString() ??
            'Failed to save business details.',
        'statusCode':
        response.statusCode,
      };
    } catch (e) {
      debugPrint(
        'BUSINESS API ERROR => $e',
      );

      return {
        'success': false,
        'message':
        'Unable to connect to server. Please try again.',
      };
    }
  }
}