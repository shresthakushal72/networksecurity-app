import 'package:wifi_scan/wifi_scan.dart';
import '../models/wifi_network.dart';
import 'dart:async';

/// Controller for WiFi scanning operations
/// This class handles all WiFi scanning logic, permissions, and auto-scanning
class WiFiScannerController {
  // ==================== PRIVATE FIELDS ====================
  List<WiFiNetwork> _networks = [];
  bool _isScanning = false;
  String _scanStatus = 'Ready to scan';
  Timer? _scanTimer;

  // ==================== PUBLIC GETTERS ====================
  List<WiFiNetwork> get networks => _networks;
  bool get isScanning => _isScanning;
  String get scanStatus => _scanStatus;

  // ==================== PERMISSION MANAGEMENT ====================

  /// Check if the app has all required permissions for WiFi scanning
  /// This method checks WiFi scan permissions and location access
  Future<void> checkPermissions() async {
    try {
      // Check if we can get scan results and start scans
      final canGetScannedResults = await WiFiScan.instance.canGetScannedResults();
      final canStartScan = await WiFiScan.instance.canStartScan();
      
      if (canGetScannedResults == CanGetScannedResults.yes && canStartScan == CanStartScan.yes) {
        _scanStatus = 'Ready to scan - All permissions granted';
        // Auto-scan when requirements are met
        _autoScan();
      } else if (canGetScannedResults == CanGetScannedResults.yes && canStartScan != CanStartScan.yes) {
        _scanStatus = 'Cannot start scan: $canStartScan\nPlease:\n• Enable WiFi\n• Enable Location Services\n• Grant location permission to this app';
      } else if (canGetScannedResults != CanGetScannedResults.yes && canStartScan == CanStartScan.yes) {
        _scanStatus = 'Cannot read results: $canGetScannedResults\nPlease:\n• Enable WiFi\n• Enable Location Services\n• Grant location permission to this app';
      } else {
        _scanStatus = 'WiFi scanning requires:\n• WiFi enabled\n• Location Services enabled\n• Location permission granted to this app\n\nCurrent status: Start=$canStartScan, Get=$canGetScannedResults';
      }
    } catch (e) {
      _scanStatus = 'Permission check failed: $e\nPlease:\n• Enable WiFi\n• Enable Location Services\n• Grant location permission to this app';
    }
  }

  // ==================== AUTO-SCANNING FEATURES ====================

  /// Automatically start scanning when all requirements are met
  /// This provides a better user experience by scanning automatically
  void _autoScan() {
    // Add a small delay to ensure UI is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_isScanning && _networks.isEmpty) {
        startScan();
      }
    });
  }

  /// Start monitoring permissions every 3 seconds for auto-scanning
  /// This allows the app to automatically scan when permissions become available
  void startPermissionMonitoring() {
    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkAndAutoScan();
    });
  }

  /// Check if permissions are now available and auto-scan if possible
  /// This method runs every 3 seconds to detect when WiFi/Location become available
  Future<void> _checkAndAutoScan() async {
    try {
      final canGetScannedResults = await WiFiScan.instance.canGetScannedResults();
      final canStartScan = await WiFiScan.instance.canStartScan();
      
      // If permissions become available and we're not already scanning
      if (canGetScannedResults == CanGetScannedResults.yes && 
          canStartScan == CanStartScan.yes && 
          !_isScanning && 
          _networks.isEmpty) {
        _scanStatus = 'Requirements met - Auto-scanning...';
        startScan();
      }
    } catch (e) {
      // Ignore errors during periodic checking
    }
  }

  // ==================== MAIN SCANNING METHODS ====================

  /// Start a WiFi network scan
  /// This method handles the entire scanning process from start to finish
  Future<void> startScan() async {
    _isScanning = true;
    _scanStatus = 'Scanning...';
    _networks.clear();

    try {
      // First check permissions again before starting
      final canStartScan = await WiFiScan.instance.canStartScan();
      final canGetResults = await WiFiScan.instance.canGetScannedResults();
      
      _scanStatus = 'Checking permissions... CanStart: $canStartScan, CanGet: $canGetResults';
      
      if (canStartScan == CanStartScan.yes && canGetResults == CanGetScannedResults.yes) {
        _scanStatus = 'Starting WiFi scan...';
        
        // Start the scan
        final startResult = await WiFiScan.instance.startScan();
        _scanStatus = 'Scan started: $startResult';
        
        // Wait longer and try more times for real devices
        bool scanCompleted = false;
        int attempts = 0;
        const maxAttempts = 10; // Increased from 3 to 10 for better reliability
        
        while (!scanCompleted && attempts < maxAttempts) {
          attempts++;
          _scanStatus = 'Waiting for scan results... Attempt $attempts/$maxAttempts';
          
          // Wait 2 seconds between attempts for real devices
          await Future.delayed(const Duration(seconds: 2));
          
          try {
            // Try to get scan results
            final results = await WiFiScan.instance.getScannedResults();
            if (results.isNotEmpty) {
              _processScanResults(results);
              scanCompleted = true;
              _scanStatus = 'Found ${_networks.length} networks';
            } else {
              _scanStatus = 'No results yet, waiting... Attempt $attempts/$maxAttempts';
            }
          } catch (e) {
            _scanStatus = 'Error getting results: $e\nAttempt $attempts/$maxAttempts';
          }
        }
        
        if (!scanCompleted) {
          _scanStatus = 'Scan timeout - No networks found after $maxAttempts attempts';
        }
      } else {
        _scanStatus = 'Cannot scan: Start=$canStartScan, Get=$canGetResults\nPlease enable WiFi and Location Services';
      }
    } catch (e) {
      _scanStatus = 'Scan failed: $e\nPlease check WiFi and Location Services';
    } finally {
      _isScanning = false;
    }
  }

  // ==================== RESULT PROCESSING ====================

  /// Process the raw scan results and convert them to WiFiNetwork objects
  /// This method handles the conversion from WiFiAccessPoint to our custom model
  void _processScanResults(List<WiFiAccessPoint> results) {
    _networks.clear();
    
    for (final result in results) {
      try {
        // Create a WiFiNetwork object from each scan result
        final network = WiFiNetwork(
          ssid: result.ssid ?? 'Hidden Network',
          level: result.level ?? -100,
          frequency: result.frequency ?? 0,
          capabilities: result.capabilities ?? '',
        );
        
        _networks.add(network);
      } catch (e) {
        // Skip any malformed results
        continue;
      }
    }
    
    // Sort networks by signal strength (strongest first)
    _networks.sort((a, b) => b.level.compareTo(a.level));
    
    // Identify which network we're currently connected to
    _identifyConnectedNetwork();
  }

  /// Try to identify which network the device is currently connected to
  /// This helps users see their current connection status
  void _identifyConnectedNetwork() {
    // For now, we'll simulate finding the connected network
    // In a real implementation, you would check the current WiFi connection
    if (_networks.isNotEmpty) {
      // Mark the first network as connected for demonstration
      // In reality, you'd check against the actual connected network
      // Note: Since isConnected is final, we can't modify it after creation
      // This is a limitation of the current model design
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Stop the permission monitoring timer
  /// Call this when the controller is no longer needed
  void stopPermissionMonitoring() {
    _scanTimer?.cancel();
    _scanTimer = null;
  }

  /// Clear all scanned networks
  /// Useful for refreshing the scan results
  void clearNetworks() {
    _networks.clear();
    _scanStatus = 'Ready to scan';
  }

  /// Get the currently connected network (if any)
  WiFiNetwork? getConnectedNetwork() {
    try {
      return _networks.firstWhere((network) => network.isConnected);
    } catch (e) {
      return null; // No connected network found
    }
  }

  /// Check if we have any networks scanned
  bool get hasNetworks => _networks.isNotEmpty;

  /// Get the number of networks found
  int get networkCount => _networks.length;

  // ==================== PERMISSION MANAGEMENT ====================

  /// Request permissions for WiFi scanning
  /// This method provides user guidance for enabling required permissions
  Future<void> requestPermissions() async {
    _scanStatus = 'To scan WiFi networks, please:\n• Grant location permission when prompted\n• Enable Location Services in device settings\n• Ensure WiFi is enabled';
    
    // Wait a moment then recheck permissions
    await Future.delayed(const Duration(seconds: 2));
    await checkPermissions();
  }

  /// Get permission status for debugging
  String getPermissionStatus() {
    return 'Scan Status: $_scanStatus';
  }

  // ==================== RESOURCE CLEANUP ====================

  /// Clean up resources when controller is disposed
  /// This prevents memory leaks and stops background timers
  void dispose() {
    stopPermissionMonitoring();
    _networks.clear();
  }
}
