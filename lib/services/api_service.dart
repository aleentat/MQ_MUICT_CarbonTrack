import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/usage_summary.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 5);

  static String get _baseUrl =>
      dotenv.env['BASE_URL'] ?? '';

  static Future<bool> sendSummary(UsageSummary summary) async {
    if (_baseUrl.isEmpty) {
      print('BASE_URL is not set');
      return false;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/usage-summary'),
            headers: const {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(summary.toJson()),
          )
          .timeout(_timeout);

      return response.statusCode == 200 ||
          response.statusCode == 201;
    } catch (e) {
      print('API error: $e');
      return false;
    }
  }
}

