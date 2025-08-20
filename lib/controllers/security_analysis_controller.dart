import '../models/security_analysis.dart';
import '../models/wifi_network.dart';

/// Controller for WiFi security analysis
/// This class analyzes WiFi networks for security vulnerabilities and provides recommendations
class SecurityAnalysisController {
  
  // ==================== MAIN ANALYSIS METHOD ====================

  /// Analyze WiFi network security and return comprehensive security assessment
  /// This is the main method that coordinates all security checks
  SecurityAnalysis analyzeNetwork(WiFiNetwork network) {
    // Step 1: Check WPS (WiFi Protected Setup) status
    final hasWPS = _hasWPSEnabled(network.capabilities);
    final wpsVersion = _detectWPSVersion(network.capabilities, network.frequency);
    final wpsVulnerability = _getWPSVulnerability(wpsVersion);
    final wpsAttackMethods = _getWPSAttackMethods(wpsVersion);
    final wpsRecommendations = _getWPSRecommendations(wpsVersion);
    
    // Step 2: Assess overall security risk
    final securityRisk = _getSecurityRisk(network.capabilities, hasWPS);
    final riskColor = _getRiskColor(securityRisk);
    
    // Step 3: Analyze encryption and network configuration
    final encryptionStrength = _getEncryptionStrength(network.capabilities);
    final channelSecurity = _getChannelSecurity(network.frequency);
    final hiddenNetworkSecurity = _getHiddenNetworkSecurity(network.ssid);
    final isEnterprise = _isEnterpriseNetwork(network.capabilities);
    
    // Step 4: Calculate security score and provide recommendations
    final securityScore = _getSecurityScore(network.capabilities, hasWPS, network.frequency, network.ssid);
    final scoreLabel = _getSecurityScoreLabel(securityScore);
    final scoreColor = _getScoreColor(securityScore);
    final recommendations = _getSecurityRecommendations(network.capabilities, hasWPS, network.frequency, network.ssid);

    return SecurityAnalysis(
      hasWPS: hasWPS,
      wpsVersion: wpsVersion,
      wpsVulnerability: wpsVulnerability,
      wpsAttackMethods: wpsAttackMethods,
      wpsRecommendations: wpsRecommendations,
      securityRisk: securityRisk,
      riskColor: riskColor,
      encryptionStrength: encryptionStrength,
      channelSecurity: channelSecurity,
      hiddenNetworkSecurity: hiddenNetworkSecurity,
      isEnterprise: isEnterprise,
      securityScore: securityScore,
      scoreLabel: scoreLabel,
      scoreColor: scoreColor,
      recommendations: recommendations,
    );
  }

  // ==================== WPS (WiFi Protected Setup) ANALYSIS ====================

  /// Check if WPS is enabled on the network
  /// WPS can be a security vulnerability if not properly configured
  bool _hasWPSEnabled(String capabilities) {
    if (capabilities.isEmpty) return false;
    
    final wpsIndicators = [
      'WPS', 'PBC', 'PIN', 'NFC', 'USB', 'EAP', 'UPnP'
    ];
    
    final capabilitiesLower = capabilities.toLowerCase();
    return wpsIndicators.any((indicator) => 
        capabilitiesLower.contains(indicator.toLowerCase()));
  }

  /// Detect which version of WPS is being used
  /// WPS 2.0+ is much more secure than WPS 1.0
  String _detectWPSVersion(String capabilities, int frequency) {
    if (!_hasWPSEnabled(capabilities)) return 'WPS Not Available';
    
    if (capabilities.contains('WPA3')) {
      return 'WPS 2.0+ (Likely Secure) - Modern implementation with rate limiting';
    }
    
    if (capabilities.contains('WPA2') && frequency >= 5170) {
      return 'WPS 2.0 (Likely Secure) - Rate limiting and lockout protection';
    }
    
    if (capabilities.contains('WPA2') && frequency < 5170) {
      return 'WPS 1.0 or 2.0 (Unknown) - Check router settings for version';
    }
    
    if (capabilities.contains('WPA')) {
      return 'WPS 1.0 (Vulnerable) - No rate limiting, susceptible to brute force';
    }
    
    return 'WPS Version Unknown - Manual verification required';
  }

  /// Assess the vulnerability level of WPS
  /// WPS 1.0 is highly vulnerable, WPS 2.0+ is much more secure
  String _getWPSVulnerability(String wpsVersion) {
    if (wpsVersion.contains('WPS 2.0+') || wpsVersion.contains('WPS 2.0')) {
      return 'Low Risk - Modern WPS with rate limiting and lockout protection';
    }
    if (wpsVersion.contains('WPS 1.0')) {
      return 'High Risk - Vulnerable to brute force attacks, no rate limiting';
    }
    if (wpsVersion.contains('Unknown')) {
      return 'Medium Risk - Version unknown, manual verification recommended';
    }
    return 'No Risk - WPS not available';
  }

  /// List possible attack methods based on WPS version
  /// WPS 1.0 has several known attack vectors
  List<String> _getWPSAttackMethods(String wpsVersion) {
    List<String> methods = [];
    
    if (wpsVersion.contains('WPS 1.0')) {
      methods.add('🔓 Brute Force Attack - Try all 11,000 possible PINs');
      methods.add('🔓 Pixie Dust Attack - Exploit weak random number generators');
      methods.add('🔓 Offline PIN Recovery - Extract PIN from router');
      methods.add('⏱️ No Rate Limiting - Can attempt unlimited PINs');
    } else if (wpsVersion.contains('WPS 2.0')) {
      methods.add('🔒 Rate Limiting - Limited PIN attempts per hour');
      methods.add('🔒 Lockout Protection - Router locks after failed attempts');
      methods.add('🔒 Stronger Randomization - Better PIN generation');
      methods.add('⏱️ Attack takes much longer and may be detected');
    } else if (wpsVersion.contains('Unknown')) {
      methods.add('❓ Version unknown - Manual verification needed');
      methods.add('❓ Check router documentation or settings');
      methods.add('❓ Look for WPS version in router admin panel');
    }
    
    return methods;
  }

  /// Get WPS security recommendations
  List<String> _getWPSRecommendations(String wpsVersion) {
    List<String> recommendations = [];
    
    if (wpsVersion.contains('WPS 1.0')) {
      recommendations.add('🚨 IMMEDIATE ACTION REQUIRED');
      recommendations.add('🔒 Disable WPS in router settings immediately');
      recommendations.add('🔒 Use strong WPA2/WPA3 passwords instead');
      recommendations.add('🔒 Consider upgrading router firmware');
      recommendations.add('🔒 Monitor network for unauthorized access');
    } else if (wpsVersion.contains('WPS 2.0')) {
      recommendations.add('✅ WPS 2.0 is relatively secure');
      recommendations.add('🔒 Still consider disabling if not needed');
      recommendations.add('🔒 Use strong passwords as primary security');
      recommendations.add('🔒 Monitor WPS connection attempts');
    } else if (wpsVersion.contains('Unknown')) {
      recommendations.add('❓ Verify WPS version in router settings');
      recommendations.add('🔒 Disable WPS if version is 1.0');
      recommendations.add('🔒 Enable WPS 2.0 if available');
      recommendations.add('🔒 Use strong encryption passwords');
    }
    
    return recommendations;
  }

  // ==================== ENCRYPTION AND NETWORK CONFIGURATION ANALYSIS ====================

  /// Get encryption strength of the network
  /// WPA3 is the most secure, followed by WPA2, WPA, WEP, Open
  String _getEncryptionStrength(String capabilities) {
    if (capabilities.contains('WPA3')) return 'Very Strong (WPA3)';
    if (capabilities.contains('WPA2')) return 'Strong (WPA2)';
    if (capabilities.contains('WPA')) return 'Moderate (WPA)';
    if (capabilities.contains('WEP')) return 'Weak (WEP)';
    if (capabilities.contains('OPEN')) return 'None (Open)';
    return 'Unknown';
  }

  /// Determine channel security based on frequency
  /// 2.4 GHz is more prone to interference, 5 GHz is better
  String _getChannelSecurity(int frequency) {
    if (frequency >= 2400 && frequency <= 2483) {
      return '2.4 GHz - Higher congestion, potential interference';
    } else if (frequency >= 5170 && frequency <= 5825) {
      return '5 GHz - Lower congestion, better performance';
    } else if (frequency >= 5955 && frequency <= 7115) {
      return '6 GHz - Latest standard, most secure';
    }
    return 'Unknown frequency band';
  }

  /// Assess hidden network security
  /// Hidden networks are generally less secure as they don't broadcast their SSID
  String _getHiddenNetworkSecurity(String ssid) {
    if (ssid.isEmpty) {
      return 'Hidden Network - Potential security risk (SSID not broadcast)';
    }
    return 'Visible Network - Standard SSID broadcasting';
  }

  /// Check if the network is an enterprise network
  /// Enterprise networks typically use 802.1X authentication
  bool _isEnterpriseNetwork(String capabilities) {
    return capabilities.contains('802.1X') || 
           capabilities.contains('EAP') || 
           capabilities.contains('RADIUS');
  }

  // ==================== RISK ASSESSMENT ====================

  /// Get overall security risk level
  /// This combines encryption, WPS, and other factors
  String _getSecurityRisk(String capabilities, bool hasWPS) {
    if (capabilities.contains('WEP')) return 'High Risk - WEP is vulnerable';
    if (capabilities.contains('WPA') && !capabilities.contains('WPA2') && !capabilities.contains('WPA3')) {
      return hasWPS ? 'Medium-High Risk - WPA + WPS' : 'Medium Risk - WPA only';
    }
    if (capabilities.contains('WPA2') && !capabilities.contains('WPA3')) {
      return hasWPS ? 'Medium Risk - WPA2 + WPS' : 'Low-Medium Risk - WPA2';
    }
    if (capabilities.contains('WPA3')) {
      return hasWPS ? 'Low-Medium Risk - WPA3 + WPS' : 'Low Risk - WPA3';
    }
    if (capabilities.contains('OPEN')) return 'Very High Risk - No encryption';
    return 'Unknown - Check manually';
  }

  /// Get risk color based on security risk level
  int _getRiskColor(String risk) {
    if (risk.contains('Very High') || risk.contains('High')) return 0xFFF44336; // Red
    if (risk.contains('Medium-High')) return 0xFFFF9800; // Orange
    if (risk.contains('Medium')) return 0xFFFFEB3B; // Yellow
    if (risk.contains('Low-Medium')) return 0xFF8BC34A; // Light Green
    if (risk.contains('Low')) return 0xFF4CAF50; // Green
    return 0xFF9E9E9E; // Grey
  }

  // ==================== SECURITY SCORE CALCULATION ====================

  /// Calculate a security score based on various factors
  /// Higher score indicates better security
  int _getSecurityScore(String capabilities, bool hasWPS, int frequency, String ssid) {
    int score = 100;
    
    // Encryption penalties
    if (capabilities.contains('WEP')) {
      score -= 40;
    } else if (capabilities.contains('WPA') && !capabilities.contains('WPA2') && !capabilities.contains('WPA3')) score -= 20;
    else if (capabilities.contains('WPA2') && !capabilities.contains('WPA3')) score -= 10;
    else if (capabilities.contains('WPA3')) score += 10;
    
    // WPS penalty
    if (hasWPS) score -= 15;
    
    // Hidden network penalty
    if (ssid.isEmpty) score -= 10;
    
    // Frequency penalties
    if (frequency >= 2400 && frequency <= 2483) score -= 5;
    
    // Enterprise bonus
    if (_isEnterpriseNetwork(capabilities)) score += 15;
    
    return score.clamp(0, 100);
  }

  /// Get security score label
  String _getSecurityScoreLabel(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Very Good';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Fair';
    if (score >= 40) return 'Poor';
    return 'Very Poor';
  }

  /// Get score color based on security score
  int _getScoreColor(int score) {
    if (score >= 80) return 0xFF4CAF50; // Green
    if (score >= 60) return 0xFFFFEB3B; // Yellow
    if (score >= 40) return 0xFFFF9800; // Orange
    return 0xFFF44336; // Red
  }

  // ==================== RECOMMENDATIONS ====================

  /// Provide comprehensive security recommendations
  List<String> _getSecurityRecommendations(String capabilities, bool hasWPS, int frequency, String ssid) {
    List<String> recommendations = [];
    
    // Encryption recommendations
    if (capabilities.contains('WEP')) {
      recommendations.add('⚠️ Avoid WEP - Use WPA2/WPA3 instead');
    }
    if (capabilities.contains('WPA') && !capabilities.contains('WPA2') && !capabilities.contains('WPA3')) {
      recommendations.add('⚠️ Upgrade from WPA to WPA2/WPA3');
    }
    
    // WPS recommendations
    if (hasWPS) {
      recommendations.add('🔒 Disable WPS on router if possible');
      recommendations.add('🔒 Use strong passwords instead of WPS');
    }
    
    // Hidden network recommendations
    if (ssid.isEmpty) {
      recommendations.add('👁️ Hidden networks offer no security benefit');
      recommendations.add('👁️ Consider making SSID visible for better security');
    }
    
    // Frequency recommendations
    if (frequency >= 2400 && frequency <= 2483) {
      recommendations.add('📡 2.4GHz band - More vulnerable to interference');
      recommendations.add('📡 Consider 5GHz networks if available');
    }
    
    // Enterprise recommendations
    if (_isEnterpriseNetwork(capabilities)) {
      recommendations.add('🏢 Enterprise network - Requires proper authentication');
      recommendations.add('🏢 Use corporate credentials, not personal ones');
    }
    
    // General security tips
    if (capabilities.contains('WPA3')) {
      recommendations.add('✅ WPA3 is the most secure option available');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('✅ Network appears secure with current settings');
    }
    
    return recommendations;
  }
}
