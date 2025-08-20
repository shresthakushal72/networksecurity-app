import 'package:flutter/material.dart';
import '../models/wifi_network.dart';
import '../models/security_analysis.dart';
import '../controllers/security_analysis_controller.dart';

/// WiFi Details View showing security analysis and network scanning
class WiFiDetailsView extends StatefulWidget {
  final WiFiNetwork network;
  
  const WiFiDetailsView({super.key, required this.network});

  @override
  State<WiFiDetailsView> createState() => _WiFiDetailsViewState();
}

class _WiFiDetailsViewState extends State<WiFiDetailsView> {
  late SecurityAnalysisController _securityController;
  late SecurityAnalysis _securityAnalysis;

    @override
  void initState() {
    super.initState();
    _securityController = SecurityAnalysisController();

    // Analyze network security
    _securityAnalysis = _securityController.analyzeNetwork(widget.network);
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
          // Responsive header row - stack on small screens
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                // Stack layout for small screens
                return Column(
                  children: [
                    Icon(
                      Icons.wifi,
                      color: Color(_securityAnalysis.scoreColor),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.network.displayName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Color(_securityAnalysis.scoreColor),
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Security Score: ${_securityAnalysis.securityScore}/100',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(_securityAnalysis.scoreColor),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _securityAnalysis.scoreLabel,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(_securityAnalysis.scoreColor),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                // Row layout for larger screens
                return Row(
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
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
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
                );
              }
            },
          ),
          const SizedBox(height: 16),
          // Responsive info cards - scrollable on small screens
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildInfoCard('Signal', widget.network.signalStrength, Color(widget.network.signalColor)),
                const SizedBox(width: 12),
                _buildInfoCard('Frequency', '${widget.network.frequency} MHz', Colors.blue),
                const SizedBox(width: 12),
                _buildInfoCard('Security', _getShortSecurity(widget.network.capabilities), Color(_securityAnalysis.riskColor)),
              ],
            ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          // Stack layout for small screens
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
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
        } else {
          // Row layout for larger screens
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
      },
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
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 500) {
                // Stack layout for small screens
                return Column(
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
                        Expanded(
                          child: Text(
                            '🔍 Local Network Device Scanner',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                // Row layout for larger screens
                return Row(
                  children: [
                    Icon(
                      Icons.network_check,
                      color: Colors.purple[700],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '🔍 Local Network Device Scanner',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[700],
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
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
          
          // Network Info - Show status when not available
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Network Scanning Not Available Yet',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'This feature requires additional packages that are not yet implemented:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange[300]!, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Required Packages:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('• ping_discover_network - Device discovery', style: TextStyle(fontSize: 11, color: Colors.orange[600])),
                      Text('• network_tools - Port scanning', style: TextStyle(fontSize: 11, color: Colors.orange[600])),
                      Text('• arp_scan - MAC address discovery', style: TextStyle(fontSize: 11, color: Colors.orange[600])),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This feature will be available in future updates when these packages are integrated.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Scan Button - Disabled
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: null, // Disabled
              icon: const Icon(Icons.block, color: Colors.grey),
              label: const Text('Full Network Scan (Coming Soon)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.grey[400],
                foregroundColor: Colors.grey[600],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Quick Scan Button - Disabled
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: null, // Disabled
              icon: const Icon(Icons.block, color: Colors.grey),
              label: const Text('Quick Scan (Coming Soon)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.grey[400],
                foregroundColor: Colors.grey[600],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Scan Status - Show feature not available
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey, width: 1),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Feature Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Network device scanning is not yet implemented. This feature will allow you to discover connected devices, detect security cameras, and identify potential security risks on your local network.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          
          // Network Security Summary - Not available
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
                Row(
                  children: [
                    Icon(Icons.security, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Network Security Analysis',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'When network scanning becomes available, you will be able to analyze the security of all connected devices, identify potential vulnerabilities, and get recommendations for improving your network security.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue[600],
                    height: 1.4,
                  ),
                ),
              ],
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
