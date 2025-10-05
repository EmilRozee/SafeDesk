import 'package:flutter/material.dart';
import '../../models/report.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class SubstationDashboard extends StatefulWidget {
  const SubstationDashboard({super.key});

  @override
  State<SubstationDashboard> createState() => _SubstationDashboardState();
}

class _SubstationDashboardState extends State<SubstationDashboard> {
  List<Report> _assignedReports = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAssignedReports();
  }

  Future<void> _loadAssignedReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual API calls
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 1));
      final substationId = AuthService.currentUser?.substationId;
      
      setState(() {
        _assignedReports = _getMockAssignedReports();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reports: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Report> _getMockAssignedReports() {
    // Mock data for development
    return List.generate(
      5,
      (i) => Report(
        id: 'report-$i',
        category: ['Harassment', 'Fraud', 'Abuse', 'Other'][i % 4],
        description: 'Test report description $i',
        mediaUrls: [],
        location: 'Location $i',
        timestamp: DateTime.now().subtract(Duration(hours: i)),
        status: ReportStatus.values[i % ReportStatus.values.length],
        riskLevel: RiskLevel.values[i % RiskLevel.values.length],
        referenceId: 'REF${i.toString().padLeft(5, '0')}',
      ),
    );
  }

  void _updateStatus(Report report, ReportStatus newStatus) {
    // TODO: Implement actual status update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status updated to: ${newStatus.toString().split('.').last}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Substation Dashboard'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(),
                _buildStatusFilters(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadAssignedReports,
                    child: _buildReportsList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Search Reports',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          // TODO: Implement search
        },
      ),
    );
  }

  Widget _buildStatusFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ReportStatus.values
            .map(
              (status) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(status.toString().split('.').last),
                  onSelected: (selected) {
                    // TODO: Implement filtering
                  },
                  selected: false,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildReportsList() {
    return ListView.builder(
      itemCount: _assignedReports.length,
      itemBuilder: (context, index) {
        final report = _assignedReports[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            title: Text(
              'Report ${report.referenceId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Status: ${report.status.toString().split('.').last}\n${DateFormat('MMM d, y HH:mm').format(report.timestamp)}',
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getRiskLevelColor(report.riskLevel).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getRiskLevelIcon(report.riskLevel),
                color: _getRiskLevelColor(report.riskLevel),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category: ${report.category}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Description: ${report.description}'),
                    const SizedBox(height: 8),
                    Text('Location: ${report.location}'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _updateStatus(report, ReportStatus.inProgress),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Investigation'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _updateStatus(report, ReportStatus.resolved),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Mark as Resolved'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
    _searchController.dispose();
    super.dispose();
  }
}