import 'package:flutter/material.dart';
import '../models/wifi_network.dart';
import '../models/security_analysis.dart';
import '../models/network_device.dart';
import '../controllers/security_analysis_controller.dart';
import '../controllers/network_scanner_controller.dart';

/// WiFi Details View showing security analysis and network scanning
class WiFiDetailsView extends StatefulWidget {
  final WiFiNetwork network;
  
  const WiFiDetailsView({super.key, required this.network});

  @override
  State<WiFiDetailsView> createState() => _WiFiDetailsViewState();
}

class _WiFiDetailsViewState extends State<WiFiDetailsView> {
  late SecurityAnalysisController _securityController;
  late NetworkScannerController _networkController;
  late SecurityAnalysis _securityAnalysis;

  @override
  void initState() {
    super.initState();
    _securityController = SecurityAnalysisController();
    _networkController = NetworkScannerController();
    
    // Analyze network security
    _securityAnalysis = _securityController.analyzeNetwork(widget.network);
    
    // Initialize network scanner
    _networkController.initializeNetworkInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.network.displayName),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Network Header
            _buildNetworkHeader(),
            
            const SizedBox(height: 24),
            
            // Security Overview
            _buildSecurityOverview(),
            
            const SizedBox(height: 24),
            
            // WPS Security Analysis (if WPS is enabled)
            if (_securityAnalysis.hasWPS) ...[
              _buildWPSSecurityAnalysis(),
              const SizedBox(height: 24),
            ],
            
            // Risk Assessment
            _buildRiskAssessment(),
            
            const SizedBox(height: 24),
            
            // Security Recommendations
            _buildSecurityRecommendations(),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            _buildActionButtons(),
            
            const SizedBox(height: 32),
            
            // Network Device Scanning Section
            _buildNetworkScanningSection(),
            
            // Device Lists
            if (_networkController.devices.isNotEmpty) ...[
              _buildDeviceLists(),
            ],
          ],
        ),
      ),
    );
  }

  /// Build network header
  Widget _buildNetworkHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(_securityAnalysis.scoreColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(_securityAnalysis.scoreColor), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi,
                color: Color(_securityAnalysis.scoreColor),
                size: 48,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.network.displayName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Color(_securityAnalysis.scoreColor),
                    ),
                  ),
                  Text(
                    'Security Score: ${_securityAnalysis.securityScore}/100',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(_securityAnalysis.scoreColor),
                    ),
                  ),
                  Text(
                    _securityAnalysis.scoreLabel,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(_securityAnalysis.scoreColor),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoCard('Signal', widget.network.signalStrength, Color(widget.network.signalColor)),
              _buildInfoCard('Frequency', '${widget.network.frequency} MHz', Colors.blue),
              _buildInfoCard('Security', widget.network.capabilities, Color(_securityAnalysis.riskColor)),
            ],
          ),
        ],
      ),
    );
  }

  /// Build info card
  Widget _buildInfoCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build security overview
  Widget _buildSecurityOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔒 Security Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildSecurityInfoRow('Encryption:', _securityAnalysis.encryptionStrength),
              const SizedBox(height: 8),
              _buildSecurityInfoRow('Channel:', _securityAnalysis.channelSecurity),
              const SizedBox(height: 8),
              _buildSecurityInfoRow('Network Type:', _securityAnalysis.hiddenNetworkSecurity),
              if (_securityAnalysis.isEnterprise) ...[
                const SizedBox(height: 8),
                _buildSecurityInfoRow('Enterprise:', 'Yes - Corporate network'),
              ],
              const SizedBox(height: 8),
              _buildSecurityInfoRow('WPS Status:', _securityAnalysis.hasWPS ? '⚠️ Enabled (Security Risk)' : '✅ Disabled'),
              if (_securityAnalysis.hasWPS) ...[
                const SizedBox(height: 8),
                _buildSecurityInfoRow('WPS Version:', _securityAnalysis.wpsVersion),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Build security info row
  Widget _buildSecurityInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  /// Build WPS security analysis
  Widget _buildWPSSecurityAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔐 WPS Security Analysis',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(_securityAnalysis.riskColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(_securityAnalysis.riskColor), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _securityAnalysis.wpsVulnerability,
                style: TextStyle(
                  color: Color(_securityAnalysis.riskColor),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Potential Attack Methods:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ..._securityAnalysis.wpsAttackMethods.map((method) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  method,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(_securityAnalysis.riskColor),
                  ),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  /// Build risk assessment
  Widget _buildRiskAssessment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '⚠️ Risk Assessment',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(_securityAnalysis.riskColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(_securityAnalysis.riskColor), width: 1),
          ),
          child: Text(
            _securityAnalysis.securityRisk,
            style: TextStyle(
              color: Color(_securityAnalysis.riskColor),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  /// Build security recommendations
  Widget _buildSecurityRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💡 Security Recommendations',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._securityAnalysis.recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  rec,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 14,
                  ),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  /// Build action buttons
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showRiskAssessment(context),
            icon: const Icon(Icons.assessment),
            label: const Text('Full Risk Assessment'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showSecurityInfo(context),
            icon: const Icon(Icons.info),
            label: const Text('Learn More'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Build network scanning section
  Widget _buildNetworkScanningSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.network_check,
                color: Colors.purple[700],
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '🔍 Local Network Device Scanner',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Scan your local network to discover connected devices, detect security cameras, and identify potential security risks.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.purple[700],
            ),
          ),
          const SizedBox(height: 16),
          
          // Network Info
          if (_networkController.localIPAddress != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Network Information:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildNetworkInfoRow('Local IP:', _networkController.localIPAddress!),
                  if (_networkController.gatewayIP != null) _buildNetworkInfoRow('Gateway:', _networkController.gatewayIP!),
                  if (_networkController.subnetMask != null) _buildNetworkInfoRow('Subnet:', _networkController.subnetMask!),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Scan Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _networkController.isScanning ? null : _startNetworkScan,
              icon: _networkController.isScanning 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
              label: Text(_networkController.isScanning ? 'Scanning...' : 'Full Network Scan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Quick Scan Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _networkController.isScanning ? null : _startQuickScan,
              icon: _networkController.isScanning 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.flash_on),
              label: Text(_networkController.isScanning ? 'Scanning...' : 'Quick Scan (Faster)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Scan Status with Progress
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple, width: 1),
            ),
            child: Column(
              children: [
                if (_networkController.isScanning) ...[
                  LinearProgressIndicator(
                    backgroundColor: Colors.purple[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  _networkController.scanStatus,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.purple[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Network Security Summary
          if (_networkController.devices.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Text(
                _networkController.getNetworkSecuritySummary(),
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build network info row
  Widget _buildNetworkInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.purple[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.purple[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build device lists
  Widget _buildDeviceLists() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        
        // CCTV Cameras Section
        if (_networkController.getCCTVDevices().isNotEmpty) ...[
          Text(
            '📹 CCTV Cameras Detected',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 16),
          ..._networkController.getCCTVDevices().map((device) => _buildDeviceCard(device)),
          const SizedBox(height: 24),
        ],
        
        // IoT Devices Section
        if (_networkController.getIoTDevices().isNotEmpty) ...[
          Text(
            '🏠 IoT Devices',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.orange[700],
            ),
          ),
          const SizedBox(height: 16),
          ..._networkController.getIoTDevices().map((device) => _buildDeviceCard(device)),
          const SizedBox(height: 24),
        ],
        
        // All Devices Section
        Text(
          '📱 All Network Devices',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._networkController.devices.map((device) => _buildDeviceCard(device)),
      ],
    );
  }

  /// Build device card
  Widget _buildDeviceCard(NetworkDevice device) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(device.riskColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            device.deviceIcon,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          device.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${device.deviceType} - ${device.ipAddress}'),
            if (device.manufacturer != null) Text('Manufacturer: ${device.manufacturer}'),
            Text(
              'Risk: ${device.securityRisk}',
              style: TextStyle(
                color: Color(device.riskColor),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Color(device.riskColor),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            device.isOnline ? 'ONLINE' : 'OFFLINE',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => _showDeviceDetails(device),
      ),
    );
  }

  /// Start network scan
  void _startNetworkScan() async {
    await _networkController.startNetworkScan();
    setState(() {});
  }

  /// Start quick network scan
  void _startQuickScan() async {
    await _networkController.startQuickScan();
    setState(() {});
  }

  /// Show device details
  void _showDeviceDetails(NetworkDevice device) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Device: ${device.displayName}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDeviceInfoRow('IP Address:', device.ipAddress),
                if (device.hostname != null) _buildDeviceInfoRow('Hostname:', device.hostname!),
                if (device.macAddress != null) _buildDeviceInfoRow('MAC Address:', device.macAddress!),
                _buildDeviceInfoRow('Device Type:', device.deviceType),
                if (device.manufacturer != null) _buildDeviceInfoRow('Manufacturer:', device.manufacturer!),
                _buildDeviceInfoRow('Status:', device.isOnline ? 'Online' : 'Offline'),
                if (device.openPorts != null) _buildDeviceInfoRow('Open Ports:', device.openPorts!),
                if (device.services != null) _buildDeviceInfoRow('Services:', device.services!),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(device.riskColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(device.riskColor), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Security Risk: ${device.securityRisk}',
                        style: TextStyle(
                          color: Color(device.riskColor),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _networkController.getDeviceSecurityAdvice(device),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Build device info row
  Widget _buildDeviceInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// Show risk assessment
  void _showRiskAssessment(BuildContext context) {
    // TODO: Implement comprehensive risk assessment modal
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Risk Assessment'),
          content: Text('Comprehensive risk assessment for ${widget.network.displayName}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Show security info
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
