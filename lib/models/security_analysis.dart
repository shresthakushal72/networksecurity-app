/// Model class representing WiFi security analysis
class SecurityAnalysis {
  final bool hasWPS;
  final String wpsVersion;
  final String wpsVulnerability;
  final List<String> wpsAttackMethods;
  final List<String> wpsRecommendations;
  final String securityRisk;
  final int riskColor;
  final String encryptionStrength;
  final String channelSecurity;
  final String hiddenNetworkSecurity;
  final bool isEnterprise;
  final int securityScore;
  final String scoreLabel;
  final int scoreColor;
  final List<String> recommendations;

  SecurityAnalysis({
    required this.hasWPS,
    required this.wpsVersion,
    required this.wpsVulnerability,
    required this.wpsAttackMethods,
    required this.wpsRecommendations,
    required this.securityRisk,
    required this.riskColor,
    required this.encryptionStrength,
    required this.channelSecurity,
    required this.hiddenNetworkSecurity,
    required this.isEnterprise,
    required this.securityScore,
    required this.scoreLabel,
    required this.scoreColor,
    required this.recommendations,
  });

  /// Get risk level description
  String get riskLevel {
    if (riskColor == 0xFFF44336) return 'Critical'; // Red
    if (riskColor == 0xFFFF9800) return 'High'; // Orange
    if (riskColor == 0xFFFFEB3B) return 'Medium'; // Yellow
    if (riskColor == 0xFF8BC34A) return 'Low'; // Light Green
    return 'Very Low'; // Green
  }

  /// Check if immediate action is required
  bool get requiresImmediateAction {
    return riskColor == 0xFFF44336 || riskColor == 0xFFFF9800;
  }

  /// Get security status
  String get securityStatus {
    if (securityScore >= 90) return 'Excellent';
    if (securityScore >= 80) return 'Very Good';
    if (securityScore >= 70) return 'Good';
    if (securityScore >= 60) return 'Fair';
    if (securityScore >= 40) return 'Poor';
    return 'Very Poor';
  }
}
