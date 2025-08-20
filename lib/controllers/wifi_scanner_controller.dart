import 'package:wifi_scan/wifi_scan.dart';
import '../models/wifi_network.dart';
import 'dart:async';

/// Controller for WiFi scanning operations
class WiFiScannerController {
  List<WiFiNetwork> _networks = [];
  bool _isScanning = false;
  String _scanStatus = 'Ready to scan';
  Timer? _scanTimer;

  // Getters
  List<WiFiNetwork> get networks => _networks;
  bool get isScanning => _isScanning;
  String get scanStatus => _scanStatus;

  /// Check WiFi scan permissions
  Future<void> checkPermissions() async {
    try {
      final canGetScannedResults = await WiFiScan.instance.canGetScannedResults();
      final canStartScan = await WiFiScan.instance.canStartScan();
      
      if (canGetScannedResults == CanGetScannedResults.yes && canStartScan == CanStartScan.yes) {
        _scanStatus = 'Ready to scan - All permissions granted';
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

  /// Start WiFi scanning
  Future<void> startScan() async {
    _isScanning = true;
    _scanStatus = 'Scanning...';
    _networks.clear();

    try {
      // First check permissions again
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
        const maxAttempts = 10; // Increased from 3 to 10
        
        while (!scanCompleted && attempts < maxAttempts) {
          await Future.delayed(const Duration(seconds: 2)); // Increased from 1 to 2 seconds
          attempts++;
          
          _scanStatus = 'Checking results... Attempt $attempts/$maxAttempts';
          
          try {
            final results = await WiFiScan.instance.getScannedResults();
            if (results.isNotEmpty) {
              _scanStatus = 'Found ${results.length} networks!';
              _processResults(results);
              scanCompleted = true;
            } else {
              _scanStatus = 'No results yet... Attempt $attempts/$maxAttempts';
            }
          } catch (e) {
            _scanStatus = 'Error getting results: $e - Attempt $attempts/$maxAttempts';
          }
        }
        
        if (!scanCompleted) {
          _scanStatus = 'Scan failed after $maxAttempts attempts.\nPlease ensure:\n• WiFi is enabled\n• Location Services are enabled\n• Location permission is granted to this app';
          _isScanning = false;
        }
      } else if (canStartScan != CanStartScan.yes) {
        _scanStatus = 'Cannot start WiFi scan.\nPlease:\n• Enable WiFi in device settings\n• Enable Location Services\n• Grant location permission to this app';
        _isScanning = false;
      } else if (canGetResults != CanGetScannedResults.yes) {
        _scanStatus = 'Cannot read scan results.\nPlease:\n• Enable WiFi\n• Enable Location Services\n• Grant location permission to this app';
        _isScanning = false;
      } else {
        _scanStatus = 'WiFi scanning not available.\nPlease:\n• Enable WiFi\n• Enable Location Services\n• Grant location permission to this app\n\nStatus: Start=$canStartScan, Get=$canGetResults';
        _isScanning = false;
      }
    } catch (e) {
      _scanStatus = 'Scan error: $e\nPlease:\n• Enable WiFi\n• Enable Location Services\n• Grant location permission to this app';
      _isScanning = false;
    }
  }

  /// Process scan results
  void _processResults(List<WiFiAccessPoint> results) {
    // Sort by signal strength (higher is stronger)
    results.sort((a, b) => b.level.compareTo(a.level));
    
    // Convert to WiFiNetwork models and identify connected network
    final connectedNetwork = _identifyConnectedNetwork(results);
    
    // Create WiFiNetwork objects
    _networks = results.map((ap) {
      final isConnected = connectedNetwork?.ssid == ap.ssid;
      return WiFiNetwork.fromAccessPoint(ap, isConnected: isConnected);
    }).toList();
    
    _isScanning = false;
    _scanStatus = 'Found ${_networks.length} networks';
  }

  /// Identify which network the device is connected to
  WiFiAccessPoint? _identifyConnectedNetwork(List<WiFiAccessPoint> results) {
    // This is a placeholder - in a real app, check actual connection
    // For now, simulate being connected to the first network
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  /// Get connected network
  WiFiNetwork? get connectedNetwork {
    try {
      return _networks.firstWhere((n) => n.isConnected);
    } catch (e) {
      return null;
    }
  }

  /// Get all networks (no separation needed)
  List<WiFiNetwork> get allNetworks => _networks;

  /// Dispose resources
  void dispose() {
    _scanTimer?.cancel();
  }

  /// Request permissions (placeholder for now)
  Future<void> requestPermissions() async {
    _scanStatus = 'To scan WiFi networks, please:\n• Grant location permission when prompted\n• Enable Location Services in device settings\n• Ensure WiFi is enabled';
    // In a real app, you would request permissions here
    // For now, just recheck what we have
    await Future.delayed(const Duration(seconds: 2));
    await checkPermissions();
  }

  /// Get permission status for debugging
  String getPermissionStatus() {
    return 'Scan Status: $_scanStatus';
  }
}
