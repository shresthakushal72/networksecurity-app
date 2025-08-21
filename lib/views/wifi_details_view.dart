import 'package:flutter/material.dart';
import '../models/wifi_network.dart';
import '../models/security_analysis.dart';
import '../controllers/security_analysis_controller.dart';

/// WiFi Details View - Compact Design
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
    _securityAnalysis = _securityController.analyzeNetwork(widget.network);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.network.displayName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 1,
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
            // Compact network header
            _buildCompactNetworkHeader(),
            
            const SizedBox(height: 20),
            
            // Security overview
            _buildCompactSecurityOverview(),
            
            const SizedBox(height: 20),
            
            // WPS Security Analysis (if WPS is enabled)
            if (_securityAnalysis.hasWPS) ...[
              _buildCompactWPSSecurityAnalysis(),
              const SizedBox(height: 20),
            ],
            
            // Risk assessment
            _buildCompactRiskAssessment(),
            
            const SizedBox(height: 20),
            
            // Security recommendations
            _buildCompactSecurityRecommendations(),
            
            const SizedBox(height: 20),
            
            // Action buttons
            _buildCompactActionButtons(),
          ],
        ),
      ),
    );
  }

  /// Build compact network header
  Widget _buildCompactNetworkHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(_securityAnalysis.scoreColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(_securityAnalysis.scoreColor), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.wifi,
                color: Color(_securityAnalysis.scoreColor),
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.network.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(_securityAnalysis.scoreColor),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Security Score: ${_securityAnalysis.securityScore}/100',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(_securityAnalysis.scoreColor),
                      ),
                    ),
                    Text(
                      _securityAnalysis.scoreLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(_securityAnalysis.scoreColor),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Compact info row
          Row(
            children: [
              _buildCompactInfoChip('Signal', widget.network.signalStrength, Color(widget.network.signalColor)),
              const SizedBox(width: 8),
              _buildCompactInfoChip('Security', _getShortSecurity(widget.network.capabilities), Color(_securityAnalysis.riskColor)),
              const SizedBox(width: 8),
              _buildCompactInfoChip('Band', widget.network.frequencyBand, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  /// Build compact info chip
  Widget _buildCompactInfoChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Build compact security overview
  Widget _buildCompactSecurityOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔒 Security Overview',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildCompactSecurityRow('Encryption:', _securityAnalysis.encryptionStrength),
              _buildCompactSecurityRow('Channel:', _securityAnalysis.channelSecurity),
              _buildCompactSecurityRow('Network Type:', _securityAnalysis.hiddenNetworkSecurity),
              if (_securityAnalysis.isEnterprise)
                _buildCompactSecurityRow('Enterprise:', 'Yes - Corporate network'),
              _buildCompactSecurityRow('WPS Status:', _securityAnalysis.hasWPS ? '⚠️ Enabled (Risk)' : '✅ Disabled'),
              if (_securityAnalysis.hasWPS)
                _buildCompactSecurityRow('WPS Version:', _securityAnalysis.wpsVersion),
            ],
          ),
        ),
      ],
    );
  }

  /// Build compact security row
  Widget _buildCompactSecurityRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Build compact WPS security analysis
  Widget _buildCompactWPSSecurityAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔐 WPS Security Analysis',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
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
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Potential Attack Methods:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              ..._securityAnalysis.wpsAttackMethods.map((method) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '• $method',
                  style: TextStyle(
                    fontSize: 11,
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

  /// Build compact risk assessment
  Widget _buildCompactRiskAssessment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '⚠️ Risk Assessment',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
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
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  /// Build compact security recommendations
  Widget _buildCompactSecurityRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💡 Security Recommendations',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._securityAnalysis.recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        rec,
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  /// Build compact action buttons
  Widget _buildCompactActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showRiskAssessment(context),
            icon: const Icon(Icons.assessment, size: 18),
            label: const Text('Risk Assessment'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showSecurityInfo(context),
            icon: const Icon(Icons.info, size: 18),
            label: const Text('Learn More'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('This app is for educational purposes only. WiFi security is complex and cannot be fully automated.'),
                SizedBox(height: 12),
                Text('Security Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('• Use strong WPA2/WPA3 passwords'),
                Text('• Enable MAC address filtering'),
                Text('• Use a VPN'),
                Text('• Update router firmware regularly'),
                Text('• Monitor network activity'),
                Text('• Use a firewall'),
                SizedBox(height: 8),
                Text('Always verify your network security and consult professionals when needed.', 
                     style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          actions: [
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
