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
        _scanStatus = 'Ready to scan';
      } else if (canGetScannedResults == CanGetScannedResults.yes && canStartScan != CanStartScan.yes) {
        _scanStatus = 'Can read results but cannot start scan: $canStartScan';
      } else if (canGetScannedResults != CanGetScannedResults.yes && canStartScan == CanStartScan.yes) {
        _scanStatus = 'Can start scan but cannot read results: $canGetScannedResults';
      } else {
        _scanStatus = 'Permissions denied - Using sample data';
        _processSampleData();
      }
    } catch (e) {
      _scanStatus = 'Permission check failed: $e - Using sample data';
      _processSampleData();
    }
  }

  /// Start WiFi scanning
  Future<void> startScan() async {
    _isScanning = true;
    _scanStatus = 'Scanning...';
    _networks.clear();

    try {
      final canStartScan = await WiFiScan.instance.canStartScan();
      if (canStartScan == CanStartScan.yes) {
        await WiFiScan.instance.startScan();
        
        // Wait a bit for scan to complete with timeout
        bool scanCompleted = false;
        int attempts = 0;
        const maxAttempts = 3;
        
        while (!scanCompleted && attempts < maxAttempts) {
          await Future.delayed(const Duration(seconds: 1));
          attempts++;
          
          final results = await WiFiScan.instance.getScannedResults();
          if (results.isNotEmpty) {
            _processResults(results);
            scanCompleted = true;
          } else if (attempts >= maxAttempts) {
            // Fallback to sample data after timeout
            _scanStatus = 'Scan timeout - Using sample data';
            _processSampleData();
          }
        }
        
        if (!scanCompleted) {
          _isScanning = false;
        }
      } else {
        _scanStatus = 'Cannot start scan: $canStartScan - Using sample data';
        _processSampleData();
        _isScanning = false;
      }
    } catch (e) {
      _scanStatus = 'Error: $e - Using sample data';
      _processSampleData();
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

  /// Process sample data for demonstration purposes
  void _processSampleData() {
    final sampleNetworks = [
      WiFiNetwork(
        ssid: 'HomeWiFi_5G',
        level: -45,
        frequency: 5180,
        capabilities: 'WPA2-PSK-CCMP',
        isConnected: true,
      ),
      WiFiNetwork(
        ssid: 'Neighbor_Network',
        level: -67,
        frequency: 2412,
        capabilities: 'WPA2-PSK-CCMP',
        isConnected: false,
      ),
      WiFiNetwork(
        ssid: 'Office_Network',
        level: -72,
        frequency: 5220,
        capabilities: 'WPA2-EAP-CCMP',
        isConnected: false,
      ),
      WiFiNetwork(
        ssid: 'Public_WiFi',
        level: -78,
        frequency: 2437,
        capabilities: 'OPEN',
        isConnected: false,
      ),
      WiFiNetwork(
        ssid: 'Guest_Network',
        level: -81,
        frequency: 5180,
        capabilities: 'WPA2-PSK-CCMP',
        isConnected: false,
      ),
    ];
    
    _networks = sampleNetworks;
    _scanStatus = 'Found ${_networks.length} sample networks';
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
}
