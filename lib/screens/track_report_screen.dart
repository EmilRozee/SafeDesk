import 'package:flutter/material.dart';

class TrackReportScreen extends StatefulWidget {
  const TrackReportScreen({super.key});

  @override
  State<TrackReportScreen> createState() => _TrackReportScreenState();
}

class _TrackReportScreenState extends State<TrackReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  String? _status;

  @override
  void initState() {
    super.initState();
    // Check if we have a reference ID passed as argument
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final referenceId = ModalRoute.of(context)?.settings.arguments as String?;
      if (referenceId != null) {
        _referenceController.text = referenceId;
        _checkStatus();
      }
    });
  }

  void _checkStatus() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement actual status check
      // For now, randomly choose a status
      final statuses = ['Pending', 'Verified', 'Action Taken'];
      setState(() {
        _status = statuses[DateTime.now().millisecond % 3];
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Verified':
        return Colors.blue;
      case 'Action Taken':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Report'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Reference ID',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your reference ID',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a reference ID';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _checkStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Check Status',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (_status != null) ...[
              const Text(
                'Report Status:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Reference ID: ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _referenceController.text,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Status: ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(_status!).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _status!,
                              style: TextStyle(
                                color: _getStatusColor(_status!),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }
}