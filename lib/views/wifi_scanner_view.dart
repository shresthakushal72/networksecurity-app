import 'package:flutter/material.dart';
import '../controllers/wifi_scanner_controller.dart';
import '../models/wifi_network.dart';
import 'wifi_details_view.dart';

/// Main WiFi Scanner View
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
      appBar: AppBar(
        title: const Text('WiFi Security Scanner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
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
          // Legal Disclaimer Banner
          _buildLegalBanner(),
          
          // Status and Scan Button
          _buildScanSection(),
          
          // Results
          Expanded(
            child: _buildResultsSection(),
          ),
        ],
      ),
    );
  }

  /// Build legal disclaimer banner
  Widget _buildLegalBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(
          bottom: BorderSide(color: Colors.blue[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: Colors.blue[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Educational Tool - For security awareness only. Do not test networks you do not own.',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build scan section with button and status
  Widget _buildScanSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            _controller.scanStatus,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _controller.isScanning ? null : _startScan,
            icon: _controller.isScanning 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.wifi_find),
            label: Text(_controller.isScanning ? 'Scanning...' : 'Scan for WiFi'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Build results section
  Widget _buildResultsSection() {
    if (_controller.networks.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // All networks in a single list (no special treatment for connected)
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
            'No WiFi networks found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the scan button to discover networks',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual network card
  Widget _buildNetworkCard(WiFiNetwork network) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Stack(
          children: [
            Icon(
              Icons.wifi,
              color: Color(network.signalColor),
              size: 28,
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
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                network.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // Show connected badge if this is the connected network
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
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Signal: ${network.signalStrength} (${network.level} dBm)'),
            Text('Security: ${network.capabilities}'),
            Text('Frequency: ${network.frequency} MHz'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(network.signalColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${network.level}',
            style: TextStyle(
              color: Color(network.signalColor),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => _navigateToWiFiDetails(context, network),
      ),
    );
  }

  /// Start WiFi scan
  void _startScan() async {
    await _controller.startScan();
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
