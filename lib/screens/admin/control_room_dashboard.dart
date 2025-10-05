import 'package:flutter/material.dart';
import '../../models/report.dart';
import '../../models/substation.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class ControlRoomDashboard extends StatefulWidget {
  const ControlRoomDashboard({super.key});

  @override
  State<ControlRoomDashboard> createState() => _ControlRoomDashboardState();
}

class _ControlRoomDashboardState extends State<ControlRoomDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Report> _reports = [];
  List<Report> _assignedReports = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual API calls
      // For now, using mock data
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _reports = _getMockReports();
        _assignedReports = _reports.where((r) => r.status != ReportStatus.pending).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reports: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Report> _getMockReports() {
    // Mock data for development
    return List.generate(
      10,
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

  void _assignToSubstation(Report report) {
    // TODO: Implement actual assignment
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reference ID: ${report.referenceId}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Substation',
                border: OutlineInputBorder(),
              ),
              items: ['Station A', 'Station B', 'Station C']
                  .map((name) => DropdownMenuItem(
                        value: name,
                        child: Text(name),
                      ))
                  .toList(),
              onChanged: (value) {
                // TODO: Implement assignment
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Report assigned to $value'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Room Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'New Reports'),
            Tab(text: 'Assigned'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportsList(_reports.where((r) => r.status == ReportStatus.pending).toList()),
          _buildReportsList(_assignedReports),
          _buildAnalytics(),
        ],
      ),
    );
  }

  Widget _buildReportsList(List<Report> reports) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
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
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadReports,
            child: ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return _buildReportCard(report);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(Report report) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          'Report ${report.referenceId}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Location: ${report.location}\n${DateFormat('MMM d, y HH:mm').format(report.timestamp)}',
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
                const SizedBox(height: 16),
                if (report.status == ReportStatus.pending)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _assignToSubstation(report),
                        icon: const Icon(Icons.assignment_ind),
                        label: const Text('Assign to Substation'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement verification
                        },
                        icon: const Icon(Icons.verified),
                        label: const Text('Mark as Verified'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard(
            'Total Reports',
            _reports.length.toString(),
            Icons.assessment,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  _reports.where((r) => r.status == ReportStatus.pending).length.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Verified',
                  _reports.where((r) => r.status == ReportStatus.verified).length.toString(),
                  Icons.verified,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Reports by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // TODO: Add charts
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}