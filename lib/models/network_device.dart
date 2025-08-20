/// Model class representing a network device
class NetworkDevice {
  final String ipAddress;
  final String? hostname;
  final String? macAddress;
  final String deviceType;
  final String? manufacturer;
  final bool isOnline;
  final String? openPorts;
  final String? services;
  final String securityRisk;
  final int riskColor;

  NetworkDevice({
    required this.ipAddress,
    this.hostname,
    this.macAddress,
    required this.deviceType,
    this.manufacturer,
    required this.isOnline,
    this.openPorts,
    this.services,
    required this.securityRisk,
    required this.riskColor,
  });

  /// Check if device is a CCTV camera
  bool get isCCTV {
    return deviceType.toLowerCase().contains('camera') ||
           deviceType.toLowerCase().contains('cctv') ||
           manufacturer?.toLowerCase().contains('hikvision') == true ||
           manufacturer?.toLowerCase().contains('dahua') == true ||
           manufacturer?.toLowerCase().contains('axis') == true ||
           manufacturer?.toLowerCase().contains('bosch') == true ||
           openPorts?.contains('554') == true || // RTSP port
           openPorts?.contains('8000') == true || // Common camera port
           openPorts?.contains('37777') == true; // Dahua port
  }

  /// Check if device is an IoT device
  bool get isIoT {
    return deviceType.toLowerCase().contains('smart') ||
           deviceType.toLowerCase().contains('iot') ||
           deviceType.toLowerCase().contains('printer') ||
           deviceType.toLowerCase().contains('tv') ||
           deviceType.toLowerCase().contains('thermostat') ||
           deviceType.toLowerCase().contains('light') ||
           deviceType.toLowerCase().contains('switch');
  }

  /// Get device icon based on type
  String get deviceIcon {
    final type = deviceType.toLowerCase();
    if (type.contains('camera') || type.contains('cctv')) {
      return '📹';
    } else if (type.contains('router') || type.contains('gateway')) {
      return '🌐';
    } else if (type.contains('printer')) {
      return '🖨️';
    } else if (type.contains('tv')) {
      return '📺';
    } else if (type.contains('phone') || type.contains('mobile')) {
      return '📱';
    } else if (type.contains('computer') || type.contains('laptop')) {
      return '💻';
    } else if (type.contains('smart')) {
      return '🏠';
    } else {
      return '📱';
    }
  }

  /// Get display name
  String get displayName => hostname ?? ipAddress;
}
