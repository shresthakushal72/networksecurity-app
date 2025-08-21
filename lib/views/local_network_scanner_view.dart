import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../controllers/network_scanner_controller.dart';
import '../models/network_device.dart';

/// Dedicated Local Network Scanner View
class LocalNetworkScannerView extends StatefulWidget {
  const LocalNetworkScannerView({super.key});

  @override
  State<LocalNetworkScannerView> createState() => _LocalNetworkScannerViewState();
}

class _LocalNetworkScannerViewState extends State<LocalNetworkScannerView> {
  late NetworkScannerController _controller;

  @override
  void initState() {
    super.initState();
    try {
      _controller = NetworkScannerController();
      _controller.initializeNetworkInfo().catchError((e) {
        debugPrint('Failed to initialize network info: $e');
      });
    } catch (e) {
      debugPrint('Failed to create network scanner controller: $e');
      _controller = NetworkScannerController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Compact scan controls
              _buildCompactScanControls(),

              // Results section
              Expanded(
                child: _buildResultsSection(),
              ),
            ],
          ),

          // Compact scanning overlay (only when scanning)
          if (_controller.isScanning) _buildCompactScanningOverlay(),
        ],
      ),
    );
  }

  /// Build compact scan controls
  Widget _buildCompactScanControls() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Local IP indicator (compact)
          if (_controller.localIPAddress != null)
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _controller.localIPAddress!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(width: 12),

          // Scan buttons (compact)
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _controller.isScanning ? null : _startFullScan,
                    icon: _controller.isScanning
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.search, size: 16),
                    label: Text(
                      _controller.isScanning ? 'Scanning' : 'Full',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _controller.isScanning ? null : _startQuickScan,
                    icon: _controller.isScanning
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.flash_on, size: 16),
                    label: Text(
                      _controller.isScanning ? 'Scanning' : 'Quick',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build compact scanning overlay (toast-style)
  Widget _buildCompactScanningOverlay() {
    return Positioned(
      top: 80, // Below the scan controls
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue[600],
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Compact progress indicator
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            
            // Status text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Scanning Network...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_controller.devices.isNotEmpty)
                    Text(
                      'Found ${_controller.devices.length} devices',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            
            // Stop button
            GestureDetector(
              onTap: _stopScan,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.stop,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build results section
  Widget _buildResultsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple header
          Text(
            'Network Devices (${_controller.devices.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          // Device list or empty state
          Expanded(
            child: _controller.devices.isEmpty 
                ? _buildEmptyState()
                : _buildDeviceList(),
          ),
        ],
      ),
    );
  }

  /// Build device list
  Widget _buildDeviceList() {
    return ListView.builder(
      itemCount: _controller.devices.length,
      itemBuilder: (context, index) {
        final device = _controller.devices[index];
        return _buildDeviceCard(device);
      },
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.network_check,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Network Devices Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start scanning to discover devices on your network',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build individual device card
  Widget _buildDeviceCard(NetworkDevice device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Device icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(device.riskColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      device.deviceIcon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Device info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          device.deviceType,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Risk indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(device.riskColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      device.securityRisk,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Device details
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDetailChip('IP', device.ipAddress, Icons.computer, Colors.blue),
                  if (device.hostname != null)
                    _buildDetailChip('Hostname', device.hostname!, Icons.label, Colors.green),
                  if (device.manufacturer != null)
                    _buildDetailChip('Brand', device.manufacturer!, Icons.business, Colors.purple),
                  if (device.isCCTV)
                    _buildDetailChip('CCTV', 'Security Camera', Icons.videocam, Colors.red),
                  if (device.isIoT)
                    _buildDetailChip('IoT', 'Smart Device', Icons.smartphone, Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build detail chip
  Widget _buildDetailChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Start full network scan
  Future<void> _startFullScan() async {
    try {
      await _controller.startNetworkScan();
      setState(() {});
    } catch (e) {
      debugPrint('Full scan failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scan failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Start quick network scan
  Future<void> _startQuickScan() async {
    try {
      await _controller.startQuickScan();
      setState(() {});
    } catch (e) {
      debugPrint('Quick scan failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quick scan failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Stop the current scan
  void _stopScan() {
    try {
      _controller.stopScan();
      setState(() {});
    } catch (e) {
      debugPrint('Stop scan failed: $e');
    }
  }
}
