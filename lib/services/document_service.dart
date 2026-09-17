import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;

import 'package:loanready_app/Model/document_model.dart';
import 'storage_service.dart';

class DocumentService {
  static const String baseUrl =
      'https://loan.edugaondev.com/api/v1';

  final StorageService _storageService = StorageService();

  // ============================================================
  // OCR
  // ============================================================

  Future<String?> extractTextFromImage(
      String path,
      ) async {
    TextRecognizer? textRecognizer;

    try {
      final inputImage = InputImage.fromFilePath(path);

      textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );

      final RecognizedText recognizedText =
      await textRecognizer.processImage(
        inputImage,
      );

      return recognizedText.text;
    } catch (e) {
      debugPrint('OCR ERROR => $e');
      return null;
    } finally {
      await textRecognizer?.close();
    }
  }

  // ============================================================
  // TOKEN
  // ============================================================

  Future<String?> _getToken() async {
    final token = await _storageService.getToken();

    if (token == null || token.isEmpty) {
      debugPrint('DOCUMENT API => TOKEN NOT FOUND');
      return null;
    }

    return token;
  }

  // ============================================================
  // COMMON HEADERS
  // ============================================================

  Map<String, String> _headers(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // ============================================================
  // COMMON RESPONSE HANDLER
  // ============================================================

  Future<Map<String, dynamic>> _handleResponse(
      http.Response response,
      ) async {
    debugPrint('STATUS => ${response.statusCode}');
    debugPrint(
      'CONTENT TYPE => ${response.headers['content-type']}',
    );
    debugPrint('RESPONSE => ${response.body}');

    // ----------------------------------------------------------
    // Empty response
    // ----------------------------------------------------------

    if (response.body.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Server returned an empty response.',
        'statusCode': response.statusCode,
      };
    }

    // ----------------------------------------------------------
    // Decode JSON
    // ----------------------------------------------------------

    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (e) {
      debugPrint('DOCUMENT JSON ERROR => $e');

      return {
        'success': false,
        'message': 'Invalid response received from server.',
        'statusCode': response.statusCode,
        'rawResponse': response.body,
      };
    }

    // ----------------------------------------------------------
    // Response must be Map
    // ----------------------------------------------------------

    if (decoded is! Map) {
      return {
        'success': false,
        'message': 'Invalid server response format.',
        'statusCode': response.statusCode,
      };
    }

    final Map<String, dynamic> data =
    Map<String, dynamic>.from(decoded);

    // ----------------------------------------------------------
    // Unauthorized
    // ----------------------------------------------------------

    if (response.statusCode == 401) {
      await _storageService.clearToken();

      return {
        'success': false,
        'message': data['message']?.toString() ??
            'Session expired. Please login again.',
        'statusCode': 401,
        'isUnauthorized': true,
      };
    }

    // ----------------------------------------------------------
    // Success
    // ----------------------------------------------------------

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return {
        'success': data['success'] ?? true,
        'message': data['message']?.toString() ??
            'Request completed successfully.',
        'documents': data['documents'],
        'document': data['document'],
        'data': data,
        'statusCode': response.statusCode,
      };
    }

    // ----------------------------------------------------------
    // API ERROR
    // ----------------------------------------------------------

    return {
      'success': false,
      'message': data['message']?.toString() ??
          data['error']?.toString() ??
          'Request failed.',
      'statusCode': response.statusCode,
      'data': data,
    };
  }

  // ============================================================
  // CREATE
  // POST /documents
  // ============================================================

  Future<Map<String, dynamic>> uploadDocuments(
      DocumentsModel docs,
      ) async {
    final token = await _getToken();

    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found.',
      };
    }

    try {
      final url = Uri.parse('$baseUrl/documents');

      final requestBody = jsonEncode(
        docs.toJson(),
      );

      debugPrint(
        '========== CREATE DOCUMENT =========',
      );
      debugPrint('URL => $url');

      final stopwatch = Stopwatch()..start();

      final response = await http
          .post(
        url,
        headers: _headers(token),
        body: requestBody,
      )
          .timeout(
        const Duration(seconds: 20),
      );

      stopwatch.stop();

      debugPrint(
        'CREATE DOCUMENT API TIME => '
            '${stopwatch.elapsedMilliseconds} ms',
      );

      debugPrint(
        'STATUS => ${response.statusCode}',
      );

      return await _handleResponse(response);
    } on TimeoutException {
      debugPrint(
        'CREATE DOCUMENT TIMEOUT',
      );

      return {
        'success': false,
        'message':
        'Server is taking too long. Please try again.',
      };
    } catch (e) {
      debugPrint(
        'CREATE DOCUMENT ERROR => $e',
      );

      return {
        'success': false,
        'message':
        'Unable to connect to server. Please try again.',
      };
    }
  }

  // ============================================================
  // READ ALL
  // GET /documents
  // ============================================================

  Future<Map<String, dynamic>> getDocuments() async {
    final token = await _getToken();

    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found.',
      };
    }

    try {
      final url = Uri.parse('$baseUrl/documents');

      debugPrint(
        '========== GET DOCUMENTS =========',
      );

      debugPrint('URL => $url');

      final response = await http.get(
        url,
        headers: _headers(token),
      );

      debugPrint(
        '==================================',
      );

      return await _handleResponse(response);
    } catch (e) {
      debugPrint(
        'GET DOCUMENTS ERROR => $e',
      );

      return {
        'success': false,
        'message':
        'Unable to connect to server. Please try again.',
      };
    }
  }

  // ============================================================
  // READ SINGLE
  // GET /documents/:id
  // ============================================================

  Future<Map<String, dynamic>> getDocumentById(
      dynamic documentId,
      ) async {
    final token = await _getToken();

    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found.',
      };
    }

    try {
      final url = Uri.parse(
        '$baseUrl/documents/$documentId',
      );

      debugPrint(
        '========== GET DOCUMENT =========',
      );

      debugPrint('ID => $documentId');
      debugPrint('URL => $url');

      final response = await http.get(
        url,
        headers: _headers(token),
      );

      debugPrint(
        '=================================',
      );

      return await _handleResponse(response);
    } catch (e) {
      debugPrint(
        'GET DOCUMENT ERROR => $e',
      );

      return {
        'success': false,
        'message':
        'Unable to connect to server. Please try again.',
      };
    }
  }

  // ============================================================
  // UPDATE
  // PUT /documents/:id
  // ============================================================
  Future<Map<String, dynamic>> updateDocuments(
      int userId,
      DocumentsModel docs,
      ) async {
    try {
      final token =
      await _storageService.getToken();

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message':
          'Authentication token not found.',
        };
      }

      final url = Uri.parse(
        '$baseUrl/documents/$userId',
      );

      debugPrint(
        '========== UPDATE DOCUMENT =========',
      );
      debugPrint('METHOD => PUT');
      debugPrint('USER ID => $userId');
      debugPrint('URL => $url');
      debugPrint(
        'BODY => ${docs.toJson()}',
      );

      final response = await http
          .put(
        url,
        headers: {
          'Authorization':
          'Bearer $token',
          'Content-Type':
          'application/json',
          'Accept':
          'application/json',
        },
        body: jsonEncode(
          docs.toJson(),
        ),
      )
          .timeout(
        const Duration(seconds: 20),
      );

      debugPrint(
        'UPDATE STATUS => ${response.statusCode}',
      );

      debugPrint(
        'UPDATE RESPONSE => ${response.body}',
      );

      final decoded =
      jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        if (response.statusCode == 401) {
          await _storageService.clearToken();

          return {
            'success': false,
            'message':
            'Session expired. Please login again.',
            'isUnauthorized': true,
          };
        }

        if (response.statusCode >= 200 &&
            response.statusCode < 300 &&
            decoded['success'] == true) {
          return decoded;
        }

        return {
          ...decoded,
          'success': false,
          'message':
          decoded['message']?.toString() ??
              'Failed to update documents.',
        };
      }

      return {
        'success': false,
        'message':
        'Invalid server response.',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message':
        'Document update timed out.',
      };
    } catch (e) {
      debugPrint(
        'UPDATE DOCUMENT ERROR => $e',
      );

      return {
        'success': false,
        'message':
        'Failed to update documents.',
      };
    }
  }
  // ============================================================
  // PATCH UPDATE
  // PATCH /documents/:id
  // ============================================================

  Future<Map<String, dynamic>> patchDocuments(
      dynamic documentId,
      Map<String, dynamic> data,
      ) async {
    final token = await _getToken();

    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found.',
      };
    }

    try {
      final url = Uri.parse(
        '$baseUrl/documents/$documentId',
      );

      final requestBody = jsonEncode(data);

      debugPrint(
        '========== PATCH DOCUMENT =========',
      );

      debugPrint('ID => $documentId');
      debugPrint('URL => $url');
      debugPrint('REQUEST => $requestBody');

      final response = await http.patch(
        url,
        headers: _headers(token),
        body: requestBody,
      );

      debugPrint(
        '====================================',
      );

      return await _handleResponse(response);
    } catch (e) {
      debugPrint(
        'PATCH DOCUMENT ERROR => $e',
      );

      return {
        'success': false,
        'message':
        'Unable to connect to server. Please try again.',
      };
    }
  }

  // ============================================================
  // DELETE
  // DELETE /documents/:id
  // ============================================================

  Future<Map<String, dynamic>> deleteDocument(
      dynamic documentId,
      ) async {
    final token = await _getToken();

    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found.',
      };
    }

    try {
      final url = Uri.parse(
        '$baseUrl/documents/$documentId',
      );

      debugPrint(
        '========== DELETE DOCUMENT =========',
      );

      debugPrint('ID => $documentId');
      debugPrint('URL => $url');

      final response = await http.delete(
        url,
        headers: _headers(token),
      );

      debugPrint(
        '====================================',
      );

      return await _handleResponse(response);
    } catch (e) {
      debugPrint(
        'DELETE DOCUMENT ERROR => $e',
      );

      return {
        'success': false,
        'message':
        'Unable to connect to server. Please try again.',
      };
    }
  }

  // ============================================================
  // DELETE ALL DOCUMENTS
  // DELETE /documents
  // ============================================================

  Future<Map<String, dynamic>> deleteAllDocuments() async {
    final token = await _getToken();

    if (token == null) {
      return {
        'success': false,
        'message': 'Authentication token not found.',
      };
    }

    try {
      final url = Uri.parse(
        '$baseUrl/documents',
      );

      debugPrint(
        '========== DELETE ALL DOCUMENTS =========',
      );

      debugPrint('URL => $url');

      final response = await http.delete(
        url,
        headers: _headers(token),
      );

      debugPrint(
        '=========================================',
      );

      return await _handleResponse(response);
    } catch (e) {
      debugPrint(
        'DELETE ALL DOCUMENTS ERROR => $e',
      );

      return {
        'success': false,
        'message':
        'Unable to connect to server. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> fetchDocuments() async {
    final token = await _storageService.getToken();

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Authentication token not found',
      };
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/documents'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.body.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Server returned empty response',
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true) {
        return {
          'success': true,
          'documents': data['documents'],
        };
      }

      if (response.statusCode == 401) {
        await _storageService.clearToken();

        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'isUnauthorized': true,
        };
      }

      return {
        'success': false,
        'message':
        data['message'] ?? 'Failed to fetch documents',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}