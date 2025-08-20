import 'package:wifi_scan/wifi_scan.dart';

/// Model class representing a WiFi network
class WiFiNetwork {
  final String ssid;
  final int level;
  final int frequency;
  final String capabilities;
  final bool isConnected;

  WiFiNetwork({
    required this.ssid,
    required this.level,
    required this.frequency,
    required this.capabilities,
    this.isConnected = false,
  });

  /// Create WiFiNetwork from WiFiAccessPoint
  factory WiFiNetwork.fromAccessPoint(WiFiAccessPoint ap, {bool isConnected = false}) {
    return WiFiNetwork(
      ssid: ap.ssid,
      level: ap.level,
      frequency: ap.frequency,
      capabilities: ap.capabilities,
      isConnected: isConnected,
    );
  }

  /// Get signal strength description
  String get signalStrength {
    if (level >= -50) return 'Excellent';
    if (level >= -60) return 'Very Good';
    if (level >= -70) return 'Good';
    if (level >= -80) return 'Fair';
    return 'Poor';
  }

  /// Get signal color for UI
  int get signalColor {
    if (level >= -50) return 0xFF4CAF50; // Green
    if (level >= -60) return 0xFF8BC34A; // Light Green
    if (level >= -70) return 0xFFFFEB3B; // Yellow
    if (level >= -80) return 0xFFFF9800; // Orange
    return 0xFFF44336; // Red
  }

  /// Check if network is hidden
  bool get isHidden => ssid.isEmpty;

  /// Get display name
  String get displayName => isHidden ? 'Hidden Network' : ssid;
}
