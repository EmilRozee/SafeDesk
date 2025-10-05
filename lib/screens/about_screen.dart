import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About SafeDesk'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              icon: Icons.security,
              title: 'Anonymous Reporting',
              description:
                  'SafeDesk ensures your identity remains protected while submitting reports. Our platform uses advanced encryption to secure your data.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              icon: Icons.policy,
              title: 'Direct Police Access',
              description:
                  'All reports are sent directly to the police control room for immediate verification and necessary action. This ensures quick response to urgent situations.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              icon: Icons.lock,
              title: 'Tamper-Proof System',
              description:
                  'Your reports are encrypted and stored securely. Our system maintains data integrity and prevents unauthorized modifications.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              icon: Icons.track_changes,
              title: 'Track Your Reports',
              description:
                  'Each report gets a unique reference ID. Use this ID to track the status of your report and stay updated on the actions taken.',
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              '© 2025 SafeDesk',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}