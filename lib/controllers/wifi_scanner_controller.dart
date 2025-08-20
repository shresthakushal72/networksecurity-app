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
    final canGetScannedResults = await WiFiScan.instance.canGetScannedResults();
    if (canGetScannedResults == CanGetScannedResults.yes) {
      _scanStatus = 'Ready to scan';
    } else {
      _scanStatus = 'Permission denied';
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
        
        // Start timer to check for results
        _scanTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
          final results = await WiFiScan.instance.getScannedResults();
          if (results.isNotEmpty) {
            timer.cancel();
            _processResults(results);
          }
        });
      } else {
        _scanStatus = 'Cannot start scan: $canStartScan';
        _isScanning = false;
      }
    } catch (e) {
      _scanStatus = 'Error: $e';
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

    // Reorder to show connected network at top
    _reorderNetworks();
    
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

  /// Reorder networks to show connected network at top
  void _reorderNetworks() {
    final connectedNetworks = _networks.where((n) => n.isConnected).toList();
    final otherNetworks = _networks.where((n) => !n.isConnected).toList();
    _networks = [...connectedNetworks, ...otherNetworks];
  }

  /// Get connected network
  WiFiNetwork? get connectedNetwork {
    try {
      return _networks.firstWhere((n) => n.isConnected);
    } catch (e) {
      return null;
    }
  }

  /// Get other available networks
  List<WiFiNetwork> get otherNetworks {
    return _networks.where((n) => !n.isConnected).toList();
  }

  /// Dispose resources
  void dispose() {
    _scanTimer?.cancel();
  }
}
