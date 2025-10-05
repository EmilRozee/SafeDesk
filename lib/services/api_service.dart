import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/report.dart';

class ApiService {
  static const String baseUrl = 'https://api.safedesk.com'; // Replace with actual API URL
  static const String _reportsKey = 'local_reports';

  // Submit a new report
  static Future<Report> submitReport(Report report) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reports'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(report.toJson()),
      );

      if (response.statusCode == 201) {
        final reportData = jsonDecode(response.body);
        return Report.fromJson(reportData);
      }

      // For development, store locally
      await _storeReportLocally(report);
      return report;
    } catch (e) {
      print('Error submitting report: $e');
      await _storeReportLocally(report);
      return report;
    }
  }

  // Get report status by reference ID
  static Future<Report?> getReportStatus(String referenceId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reports/$referenceId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final reportData = jsonDecode(response.body);
        return Report.fromJson(reportData);
      }

      // For development, get from local storage
      return await _getReportLocally(referenceId);
    } catch (e) {
      print('Error getting report status: $e');
      return await _getReportLocally(referenceId);
    }
  }

  // Upload media files
  static Future<List<String>> uploadMedia(List<String> filePaths) async {
    // TODO: Implement actual file upload to S3/Firebase
    // For now, return mock URLs
    return filePaths.map((path) => 'https://storage.safedesk.com/mock/$path').toList();
  }

  // Store report locally for development
  static Future<void> _storeReportLocally(Report report) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reports = await _getLocalReports();
      reports[report.referenceId] = report.toJson();
      await prefs.setString(_reportsKey, jsonEncode(reports));
    } catch (e) {
      print('Error storing report locally: $e');
    }
  }

  // Get report from local storage
  static Future<Report?> _getReportLocally(String referenceId) async {
    try {
      final reports = await _getLocalReports();
      final reportData = reports[referenceId];
      if (reportData != null) {
        return Report.fromJson(Map<String, dynamic>.from(reportData));
      }
    } catch (e) {
      print('Error getting report locally: $e');
    }
    return null;
  }

  // Get all local reports
  static Future<Map<String, dynamic>> _getLocalReports() async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson = prefs.getString(_reportsKey);
    if (reportsJson != null) {
      return Map<String, dynamic>.from(jsonDecode(reportsJson));
    }
    return {};
  }
}