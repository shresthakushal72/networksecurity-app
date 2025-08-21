import 'package:flutter/material.dart';
import '../controllers/wifi_scanner_controller.dart';
import '../models/wifi_network.dart';
import 'wifi_details_view.dart';

/// Main WiFi Scanner View - Compact Design
class WiFiScannerView extends StatefulWidget {
  const WiFiScannerView({super.key});

  @override
  State<WiFiScannerView> createState() => _WiFiScannerViewState();
}

class _WiFiScannerViewState extends State<WiFiScannerView> {
  late WiFiScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WiFiScannerController();
    _controller.checkPermissions();
    _controller.startPermissionMonitoring();
  }

  @override
  void dispose() {
    _controller.stopPermissionMonitoring();
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
      child: Column(
        children: [
          // Status display (compact)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _controller.scanStatus,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Action buttons (compact)
          Row(
            children: [
              // Scan button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _controller.isScanning ? null : _startScan,
                  icon: _controller.isScanning 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.wifi_find, size: 16),
                  label: Text(
                    _controller.isScanning ? 'Scanning...' : 'Scan WiFi',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Permission buttons (when needed)
              if (_controller.scanStatus.contains('Enable') || _controller.scanStatus.contains('Grant') || _controller.scanStatus.contains('requires'))
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _requestPermissions(),
                    icon: const Icon(Icons.security, size: 16),
                    label: const Text(
                      'Permissions',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Additional info (only when needed)
          if (_controller.scanStatus.contains('requires') || _controller.scanStatus.contains('Enable'))
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'WiFi & Location required for scanning',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
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
      top: 120, // Below the scan controls
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
                    'Scanning WiFi Networks...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_controller.networks.isNotEmpty)
                    Text(
                      'Found ${_controller.networks.length} networks',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get status icon based on current status
  IconData _getStatusIcon() {
    if (_controller.isScanning) return Icons.radar;
    if (_controller.scanStatus.contains('denied') || _controller.scanStatus.contains('cannot')) {
      return Icons.error_outline;
    }
    if (_controller.scanStatus.contains('WiFi is disabled')) {
      return Icons.wifi_off;
    }
    if (_controller.networks.isNotEmpty) {
      return Icons.check_circle;
    }
    return Icons.info_outline;
  }

  /// Get status color based on current status
  Color _getStatusColor() {
    if (_controller.isScanning) return Colors.blue;
    if (_controller.scanStatus.contains('denied') || _controller.scanStatus.contains('cannot')) {
      return Colors.orange;
    }
    if (_controller.scanStatus.contains('WiFi is disabled')) {
      return Colors.red;
    }
    if (_controller.networks.isNotEmpty) {
      return Colors.green;
    }
    return Colors.grey;
  }

  /// Build results section
  Widget _buildResultsSection() {
    if (_controller.networks.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Networks list with pull to refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: _startScan,
              color: Colors.blue[600],
              backgroundColor: Colors.white,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: _controller.networks.length,
                itemBuilder: (context, index) {
                  final network = _controller.networks[index];
                  return _buildNetworkCard(network);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No WiFi Networks Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to scan or use the scan button above',
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

  /// Build individual network card
  Widget _buildNetworkCard(WiFiNetwork network) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _navigateToWiFiDetails(context, network),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with WiFi icon, name, and badges
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // WiFi icon with signal strength indicator
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(network.signalColor).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Icon(
                            Icons.wifi,
                            color: Color(network.signalColor),
                            size: 24,
                          ),
                          // Show connected indicator if this is the connected network
                          if (network.isConnected)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white, width: 1),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 8,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Network name and details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            network.displayName,
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
                            'Signal: ${network.signalStrength} (${network.level} dBm)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    
                    // Badges column - make it more compact
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Connected badge
                        if (network.isConnected)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'CONNECTED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        
                        if (network.isConnected) const SizedBox(height: 3),
                        
                        // Frequency band badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(network.frequencyBandColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            network.frequencyBand,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Network details in a grid layout
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDetailItem(
                      'Security',
                      _getShortSecurity(network.capabilities),
                      Icons.security,
                      Colors.orange,
                    ),
                    _buildDetailItem(
                      'Band',
                      network.frequencyBand,
                      Icons.radio,
                      Color(network.frequencyBandColor),
                    ),
                    _buildDetailItem(
                      'Level',
                      '${network.level}',
                      Icons.signal_cellular_alt,
                      Color(network.signalColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build detail item for network card
  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Get shortened security string to prevent overflow
  String _getShortSecurity(String capabilities) {
    if (capabilities.contains('WPA3')) return 'WPA3';
    if (capabilities.contains('WPA2')) return 'WPA2';
    if (capabilities.contains('WPA')) return 'WPA';
    if (capabilities.contains('WEP')) return 'WEP';
    if (capabilities.contains('OPEN')) return 'Open';
    if (capabilities.contains('EAP')) return 'Enterprise';
    
    // If still too long, truncate
    if (capabilities.length > 15) {
      return '${capabilities.substring(0, 12)}...';
    }
    return capabilities;
  }

  /// Start WiFi scan
  Future<void> _startScan() async {
    await _controller.startScan();
    setState(() {});
    
    // Show toast notification when networks are found
    if (_controller.networks.isNotEmpty) {
      _showToastNotification('Found ${_controller.networks.length} Networks');
    }
  }

  /// Request permissions
  void _requestPermissions() async {
    await _controller.requestPermissions();
    setState(() {});
  }

  /// Navigate to WiFi details page
  void _navigateToWiFiDetails(BuildContext context, WiFiNetwork network) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WiFiDetailsView(network: network),
      ),
    );
  }

  /// Show toast notification
  void _showToastNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.wifi,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
