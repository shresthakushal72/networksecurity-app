import 'package:flutter/material.dart';
import '../controllers/wifi_scanner_controller.dart';
import '../models/wifi_network.dart';
import 'wifi_details_view.dart';

/// Main WiFi Scanner View - PortDroid Style
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
      appBar: AppBar(
        title: const Text(
          'WiFi Security Scanner',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showSecurityInfo(context),
            tooltip: 'Security Information',
          ),
        ],
      ),
      body: Column(
        children: [
          // PortDroid-style header card
          _buildHeaderCard(),
          
          // Scan controls
          _buildScanControls(),
          
          // Results section
          Expanded(
            child: _buildResultsSection(),
          ),
        ],
      ),
    );
  }

  /// Build PortDroid-style header card
  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // App icon and title
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.wifi_find,
              size: 32,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'WiFi Security Scanner',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan and analyze WiFi networks for security vulnerabilities',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build scan controls section
  Widget _buildScanControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Status display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
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
                        maxLines: 8,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                // Additional explanation for requirements
                if (_controller.scanStatus.contains('requires') || _controller.scanStatus.contains('Enable'))
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Android requires both WiFi and Location to be enabled for network scanning. This is a system security requirement.',
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
          ),
          const SizedBox(height: 16),
          
          // Action buttons
          Column(
            children: [
              // Permission/Settings buttons (when needed)
              if (_controller.scanStatus.contains('Enable') || _controller.scanStatus.contains('Grant') || _controller.scanStatus.contains('requires'))
                Row(
                  children: [
                    // Location Settings button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openLocationSettings(),
                        icon: const Icon(Icons.location_on, size: 18),
                        label: const Text('Location'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // WiFi Settings button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openWiFiSettings(),
                        icon: const Icon(Icons.wifi_off, size: 18),
                        label: const Text('WiFi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // App Permissions button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _requestPermissions(),
                        icon: const Icon(Icons.security, size: 18),
                        label: const Text('Permissions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              
              // Spacing when buttons are shown
              if (_controller.scanStatus.contains('Enable') || _controller.scanStatus.contains('Grant') || _controller.scanStatus.contains('requires'))
                const SizedBox(height: 12),
              
              // Main scan button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _controller.isScanning ? null : _startScan,
                  icon: _controller.isScanning 
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.wifi_find, size: 18),
                  label: Text(
                    _controller.isScanning ? 'Scanning...' : 'Scan WiFi Networks',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
          // Results header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Icon(
                  Icons.wifi,
                  color: Colors.blue[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Found ${_controller.networks.length} Networks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          
          // Networks list
          Expanded(
            child: ListView.builder(
              itemCount: _controller.networks.length,
              itemBuilder: (context, index) {
                final network = _controller.networks[index];
                return _buildNetworkCard(network);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
              'Tap the scan button to discover nearby networks',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
                    const SizedBox(width: 16),
                    
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
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Signal: ${network.signalStrength} (${network.level} dBm)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Badges column
                    Column(
                      children: [
                        // Connected badge
                        if (network.isConnected)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'CONNECTED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 4),
                        
                        // Frequency band badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(network.frequencyBandColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            network.frequencyBand,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
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
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Security',
                        _getShortSecurity(network.capabilities),
                        Icons.security,
                        Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Band',
                        network.frequencyBand,
                        Icons.radio,
                        Color(network.frequencyBandColor),
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Level',
                        '${network.level}',
                        Icons.signal_cellular_alt,
                        Color(network.signalColor),
                      ),
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Build compact info chip
  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$label: $value',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Build frequency band chip
  Widget _buildFrequencyBandChip(String band, int colorValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(colorValue),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.radio, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              band,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
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
  void _startScan() async {
    await _controller.startScan();
    setState(() {});
  }

  /// Request permissions
  void _requestPermissions() async {
    await _controller.requestPermissions();
    setState(() {});
  }

  /// Open WiFi settings
  void _openWiFiSettings() {
    // Show a dialog to guide user to WiFi settings
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.wifi, color: Colors.blue),
              SizedBox(width: 8),
              Text('Enable WiFi'),
            ],
          ),
          content: const Text(
            'WiFi must be enabled to scan for networks:\n\n'
            '1. Go to Settings\n'
            '2. Tap on WiFi\n'
            '3. Turn on WiFi\n'
            '4. Return to this app and try scanning again',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  /// Open Location settings
  void _openLocationSettings() {
    // Show a dialog to guide user to Location settings
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_on, color: Colors.orange),
              SizedBox(width: 8),
              Text('Enable Location'),
            ],
          ),
          content: const Text(
            'Location Services are required for WiFi scanning on Android:\n\n'
            '1. Go to Settings\n'
            '2. Tap on Location\n'
            '3. Turn on Location Services\n'
            '4. Also grant location permission to this app\n'
            '5. Return to this app and try scanning again',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
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

  /// Show security information dialog
  void _showSecurityInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('WiFi Security Information'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This app is for educational purposes only. WiFi security is complex and cannot be fully automated. Always verify your router\'s settings and use strong passwords.'),
                SizedBox(height: 16),
                Text('WPS (Wi-Fi Protected Setup) is a simple way to connect to a Wi-Fi network, but it can be vulnerable to brute force attacks. If your router supports WPS, it\'s recommended to disable it.'),
                SizedBox(height: 16),
                Text('To improve your WiFi security, consider:'),
                SizedBox(height: 8),
                Text('• 🔒 Use strong WPA2/WPA3 passwords'),
                Text('• 🔒 Enable MAC address filtering'),
                Text('• 🔒 Use a VPN'),
                Text('• 🔒 Regularly update your router firmware'),
                Text('• 🔒 Monitor network activity'),
                Text('• 🔒 Use a firewall'),
                Text('• 🔒 Consider using a wired connection instead of WiFi'),
                SizedBox(height: 16),
                Text('Always verify the security of your network and your router\'s settings. If you are unsure, consult a professional.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
