import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../models/report.dart';
import '../services/ai_service.dart';
import '../services/api_service.dart';
import '../services/encryption_service.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String _category = 'Harassment';
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final List<String> _mediaFiles = [];
  bool _isAnalyzing = false;
  RiskLevel? _riskLevel;

  final List<String> _categories = [
    'Harassment',
    'Fraud',
    'Abuse',
    'Other',
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _mediaFiles.add(image.path);
      });
    }
  }

  Future<void> _analyzeReport() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Analyze text content
      final riskLevel = await AIService.analyzeText(_descriptionController.text);
      
      // Analyze media if present
      if (_mediaFiles.isNotEmpty) {
        // TODO: Implement media analysis
      }

      setState(() {
        _riskLevel = riskLevel;
      });
    } catch (e) {
      print('Error analyzing report: $e');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isAnalyzing = true;
      });

      try {
        // Generate a unique reference ID
        final referenceId = const Uuid().v4().substring(0, 8).toUpperCase();

        // Analyze report content if not already analyzed
        if (_riskLevel == null) {
          await _analyzeReport();
        }

        // Upload media files
        final mediaUrls = await ApiService.uploadMedia(_mediaFiles);

        // Create report object
        final report = Report(
          id: const Uuid().v4(),
          category: _category,
          description: _descriptionController.text,
          mediaUrls: mediaUrls,
          location: _locationController.text,
          timestamp: DateTime.now(),
          contactInfo: _contactController.text.isNotEmpty
              ? EncryptionService.encryptData(_contactController.text)
              : null,
          riskLevel: _riskLevel ?? RiskLevel.unassessed,
          referenceId: referenceId,
        );

        // Submit report
        await ApiService.submitReport(report);

        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          '/confirmation',
          arguments: referenceId,
        );
      } catch (e) {
        print('Error submitting report: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error submitting report. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Report'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category dropdown
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _category = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      hintText: 'Provide detailed information about the incident...',
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    onChanged: (_) {
                      // Reset risk level when description changes
                      setState(() {
                        _riskLevel = null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  // Analyze button
                  if (!_isAnalyzing && _descriptionController.text.isNotEmpty)
                    TextButton.icon(
                      onPressed: _analyzeReport,
                      icon: const Icon(Icons.analytics),
                      label: const Text('Analyze Content'),
                    ),
                  
                  // Risk level indicator
                  if (_riskLevel != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getRiskLevelColor(_riskLevel!).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getRiskLevelIcon(_riskLevel!),
                            color: _getRiskLevelColor(_riskLevel!),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Risk Level: ${_riskLevel.toString().split('.').last}',
                            style: TextStyle(
                              color: _getRiskLevelColor(_riskLevel!),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  
                  // Media upload section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Evidence (Optional)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('Add Photo/Video'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black87,
                            ),
                          ),
                          if (_mediaFiles.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${_mediaFiles.length} file(s) selected',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Location field
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter a location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Contact information field
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Information (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.contact_phone),
                      helperText: 'This information will be encrypted',
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isAnalyzing ? null : _submitReport,
                      child: Text(
                        _isAnalyzing ? 'Processing...' : 'Submit Report',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isAnalyzing)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Color _getRiskLevelColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.critical:
        return Colors.red;
      case RiskLevel.high:
        return Colors.orange;
      case RiskLevel.medium:
        return Colors.yellow.shade700;
      case RiskLevel.low:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getRiskLevelIcon(RiskLevel level) {
    switch (level) {
      case RiskLevel.critical:
        return Icons.warning;
      case RiskLevel.high:
        return Icons.priority_high;
      case RiskLevel.medium:
        return Icons.info;
      case RiskLevel.low:
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }
}