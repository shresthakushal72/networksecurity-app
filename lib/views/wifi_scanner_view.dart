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
        // Connected Network Header
        if (_controller.connectedNetwork != null) ...[
          _buildConnectedNetworkHeader(_controller.connectedNetwork!),
          const SizedBox(height: 8),
        ],
        
        // Other Networks Section Header
        if (_controller.otherNetworks.isNotEmpty) ...[
          _buildOtherNetworksHeader(),
        ],
        
        // WiFi Networks List
        Expanded(
          child: _buildNetworksList(),
        ),
      ],
    );
  }

  /// Build empty state when no networks found
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the scan button to find nearby networks',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build connected network header
  Widget _buildConnectedNetworkHeader(WiFiNetwork network) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.wifi,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Currently Connected',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      network.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'CONNECTED',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildConnectedInfoCard(
                  'Signal',
                  network.signalStrength,
                  Icons.signal_wifi_4_bar,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildConnectedInfoCard(
                  'Security',
                  network.capabilities,
                  Icons.security,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildConnectedInfoCard(
                  'Frequency',
                  '${network.frequency} MHz',
                  Icons.radio,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToWiFiDetails(context, network),
              icon: const Icon(Icons.analytics),
              label: const Text('View Security Analysis & Local Network Scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build connected network info card
  Widget _buildConnectedInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build other networks header
  Widget _buildOtherNetworksHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.wifi_find,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Other Available Networks',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build networks list
  Widget _buildNetworksList() {
    return ListView.builder(
      itemCount: _controller.otherNetworks.length,
      itemBuilder: (context, index) {
        final network = _controller.otherNetworks[index];
        return _buildNetworkCard(network);
      },
    );
  }

  /// Build individual network card
  Widget _buildNetworkCard(WiFiNetwork network) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.wifi,
          color: Color(network.signalColor),
          size: 28,
        ),
        title: Text(
          network.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
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
