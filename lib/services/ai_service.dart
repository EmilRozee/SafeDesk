import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report.dart';

class AIService {
  static const String baseUrl = 'https://api.safedesk.com/ai'; // Replace with actual API URL

  // Analyze text content and assign risk score
  static Future<RiskLevel> analyzeText(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze-text'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _mapRiskScore(data['risk_score']);
      }
      
      // For development, return mock risk level
      return _mockRiskAnalysis(text);
    } catch (e) {
      print('Error analyzing text: $e');
      return RiskLevel.unassessed;
    }
  }

  // Analyze media content (images/videos)
  static Future<Map<String, dynamic>> analyzeMedia(String mediaUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze-media'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'media_url': mediaUrl}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      // For development, return mock analysis
      return {
        'contains_sensitive_content': false,
        'content_categories': [],
        'confidence_score': 0.0,
      };
    } catch (e) {
      print('Error analyzing media: $e');
      return {};
    }
  }

  // Mock risk analysis for development
  static RiskLevel _mockRiskAnalysis(String text) {
    final lowercaseText = text.toLowerCase();
    
    // Simple keyword-based mock analysis
    if (lowercaseText.contains('emergency') || 
        lowercaseText.contains('immediate') ||
        lowercaseText.contains('danger')) {
      return RiskLevel.high;
    } else if (lowercaseText.contains('urgent') || 
               lowercaseText.contains('suspicious')) {
      return RiskLevel.medium;
    } else {
      return RiskLevel.low;
    }
  }

  // Map API risk score to RiskLevel enum
  static RiskLevel _mapRiskScore(double score) {
    if (score >= 0.8) return RiskLevel.critical;
    if (score >= 0.6) return RiskLevel.high;
    if (score >= 0.4) return RiskLevel.medium;
    if (score >= 0.2) return RiskLevel.low;
    return RiskLevel.unassessed;
  }
}