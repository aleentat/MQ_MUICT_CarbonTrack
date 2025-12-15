class ApiService {
  static const Duration _timeout = Duration(seconds: 5);

  static Future<bool> sendSummary(UsageSummary summary) async {
    try {
      final response = await http
          .post(
            Uri.parse('$BASE_URL/usage-summary'),
            headers: const {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(summary.toJson()),
          )
          .timeout(_timeout);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // Network error, timeout, or parsing error
      return false;
    }
  }
}
