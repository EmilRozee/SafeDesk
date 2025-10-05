class Report {
  final String id;
  final String category;
  final String description;
  final List<String> mediaUrls;
  final String location;
  final DateTime timestamp;
  final String? contactInfo;
  final ReportStatus status;
  final RiskLevel riskLevel;
  final bool isVerified;
  final String referenceId;

  Report({
    required this.id,
    required this.category,
    required this.description,
    required this.mediaUrls,
    required this.location,
    required this.timestamp,
    this.contactInfo,
    this.status = ReportStatus.pending,
    this.riskLevel = RiskLevel.unassessed,
    this.isVerified = false,
    required this.referenceId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'description': description,
        'mediaUrls': mediaUrls,
        'location': location,
        'timestamp': timestamp.toIso8601String(),
        'contactInfo': contactInfo,
        'status': status.toString(),
        'riskLevel': riskLevel.toString(),
        'isVerified': isVerified,
        'referenceId': referenceId,
      };

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json['id'],
        category: json['category'],
        description: json['description'],
        mediaUrls: List<String>.from(json['mediaUrls']),
        location: json['location'],
        timestamp: DateTime.parse(json['timestamp']),
        contactInfo: json['contactInfo'],
        status: ReportStatus.values.firstWhere(
          (e) => e.toString() == json['status'],
          orElse: () => ReportStatus.pending,
        ),
        riskLevel: RiskLevel.values.firstWhere(
          (e) => e.toString() == json['riskLevel'],
          orElse: () => RiskLevel.unassessed,
        ),
        isVerified: json['isVerified'] ?? false,
        referenceId: json['referenceId'],
      );
}

enum ReportStatus {
  pending,
  verified,
  inProgress,
  resolved,
  archived,
  flagged
}

enum RiskLevel {
  unassessed,
  low,
  medium,
  high,
  critical
}