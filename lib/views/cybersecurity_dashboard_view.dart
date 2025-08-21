import 'package:flutter/material.dart';
import '../controllers/intrusion_detection_controller.dart';
import '../controllers/security_analysis_controller.dart';
import '../models/wifi_network.dart';
import '../models/network_device.dart';

/// Enterprise Cybersecurity Dashboard
/// Used by internal security teams for comprehensive threat monitoring and incident response
class CybersecurityDashboardView extends StatefulWidget {
  const CybersecurityDashboardView({super.key});

  @override
  State<CybersecurityDashboardView> createState() => _CybersecurityDashboardViewState();
}

class _CybersecurityDashboardViewState extends State<CybersecurityDashboardView> {
  late IntrusionDetectionController _idsController;
  late SecurityAnalysisController _securityController;
  
  // Dashboard state
  bool _isMonitoring = false;
  Map<String, dynamic> _threatStatus = {};
  Map<String, dynamic> _detailedReport = {};
  
  @override
  void initState() {
    super.initState();
    _idsController = IntrusionDetectionController();
    _securityController = SecurityAnalysisController();
    
    // Initialize dashboard
    _initializeDashboard();
  }
  
  @override
  void dispose() {
    _idsController.dispose();
    super.dispose();
  }
  
  /// Initialize dashboard with current threat status
  void _initializeDashboard() {
    _threatStatus = _idsController.getThreatStatus();
    _detailedReport = _idsController.getDetailedThreatReport();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cybersecurity Dashboard'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDashboard,
            tooltip: 'Refresh Dashboard',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: 'Dashboard Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Threat Level Overview
            _buildThreatLevelOverview(),
            
            const SizedBox(height: 20),
            
            // Monitoring Controls
            _buildMonitoringControls(),
            
            const SizedBox(height: 20),
            
            // Active Threats
            _buildActiveThreats(),
            
            const SizedBox(height: 20),
            
            // Security Metrics
            _buildSecurityMetrics(),
            
            const SizedBox(height: 20),
            
            // Incident Response
            _buildIncidentResponse(),
            
            const SizedBox(height: 20),
            
            // Threat Intelligence
            _buildThreatIntelligence(),
            
            const SizedBox(height: 20),
            
            // Quick Actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }
  
  /// Build threat level overview card
  Widget _buildThreatLevelOverview() {
    final threatLevel = _threatStatus['threat_level'] ?? 'UNKNOWN';
    final isMonitoring = _threatStatus['is_monitoring'] ?? false;
    
    Color threatColor;
    IconData threatIcon;
    
    switch (threatLevel) {
      case 'LOW':
        threatColor = Colors.green;
        threatIcon = Icons.check_circle;
        break;
      case 'MEDIUM':
        threatColor = Colors.orange;
        threatIcon = Icons.warning;
        break;
      case 'HIGH':
        threatColor = Colors.red;
        threatIcon = Icons.error;
        break;
      case 'CRITICAL':
        threatColor = Colors.red[900]!;
        threatIcon = Icons.dangerous;
        break;
      default:
        threatColor = Colors.grey;
        threatIcon = Icons.help;
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: threatColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: threatColor, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                threatIcon,
                color: threatColor,
                size: 48,
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  Text(
                    'Current Threat Level',
                    style: TextStyle(
                      fontSize: 16,
                      color: threatColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    threatLevel,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: threatColor,
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
              _buildStatusIndicator('Monitoring', isMonitoring ? 'ACTIVE' : 'INACTIVE', 
                  isMonitoring ? Colors.green : Colors.red),
              _buildStatusIndicator('Last Scan', _getLastScanTime(), Colors.blue),
              _buildStatusIndicator('Monitored', '${_threatStatus['monitored_devices'] ?? 0}', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build status indicator
  Widget _buildStatusIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  
  /// Build monitoring controls
  Widget _buildMonitoringControls() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🛡️ Threat Monitoring Controls',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggleMonitoring,
                  icon: Icon(_isMonitoring ? Icons.stop : Icons.play_arrow),
                  label: Text(_isMonitoring ? 'Stop Monitoring' : 'Start Monitoring'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isMonitoring ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _refreshDashboard,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build active threats section
  Widget _buildActiveThreats() {
    final activeThreats = _threatStatus['active_threats'] ?? <String>[];
    final detectedAnomalies = _threatStatus['detected_anomalies'] ?? <String>[];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Text(
                '🚨 Active Threats & Anomalies',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (activeThreats.isEmpty && detectedAnomalies.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'No Active Threats Detected',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Network appears secure at this time',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            if (activeThreats.isNotEmpty) ...[
              Text(
                'Active Threats (${activeThreats.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              ...activeThreats.map((threat) => _buildThreatItem(threat, true)),
              const SizedBox(height: 16),
            ],
            
            if (detectedAnomalies.isNotEmpty) ...[
              Text(
                'Detected Anomalies (${detectedAnomalies.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
              const SizedBox(height: 8),
              ...detectedAnomalies.map((anomaly) => _buildThreatItem(anomaly, false)),
            ],
          ],
        ],
      ),
    );
  }
  
  /// Build threat item
  Widget _buildThreatItem(String threat, bool isCritical) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCritical ? Colors.red[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCritical ? Colors.red[200]! : Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCritical ? Icons.dangerous : Icons.warning,
            color: isCritical ? Colors.red[700] : Colors.orange[700],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              threat,
              style: TextStyle(
                fontSize: 14,
                color: isCritical ? Colors.red[800] : Colors.orange[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showThreatDetails(threat),
            tooltip: 'View Details',
          ),
        ],
      ),
    );
  }
  
  /// Build security metrics
  Widget _buildSecurityMetrics() {
    final deviceAnalysis = _detailedReport['device_analysis'] ?? {};
    final networkAnalysis = _detailedReport['network_analysis'] ?? {};
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Security Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Monitored Devices',
                  '${deviceAnalysis['total_devices'] ?? 0}',
                  Icons.devices,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Suspicious Devices',
                  '${deviceAnalysis['suspicious_devices'] ?? 0}',
                  Icons.warning,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Failed Connections',
                  '${deviceAnalysis['failed_connections'] ?? 0}',
                  Icons.error,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build metric card
  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  /// Build incident response section
  Widget _buildIncidentResponse() {
    final incidentResponse = _detailedReport['incident_response'] ?? {};
    final responseRequired = incidentResponse['response_required'] ?? false;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: responseRequired ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: responseRequired ? Colors.red[300]! : Colors.green[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                responseRequired ? Icons.emergency : Icons.check_circle,
                color: responseRequired ? Colors.red[700] : Colors.green[700],
              ),
              const SizedBox(width: 8),
              Text(
                '🚨 Incident Response',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: responseRequired ? Colors.red[800] : Colors.green[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (responseRequired) ...[
            _buildResponseItem('Priority', incidentResponse['priority'] ?? 'UNKNOWN'),
            _buildResponseItem('Response Time', incidentResponse['estimated_response_time'] ?? 'UNKNOWN'),
            _buildResponseItem('Resources', '${(incidentResponse['required_resources'] ?? <String>[]).length} required'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _activateIncidentResponse,
              icon: const Icon(Icons.emergency),
              label: const Text('Activate Incident Response'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'No Incident Response Required',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Build response item
  Widget _buildResponseItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build threat intelligence section
  Widget _buildThreatIntelligence() {
    final threatIntel = _detailedReport['threat_intelligence'] ?? {};
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🕵️ Threat Intelligence',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Threat Categories',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(threatIntel['threat_categories'] ?? <String>[]).map((category) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $category',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Threats',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(threatIntel['latest_threats'] ?? <String>[]).map((threat) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $threat',
                          style: TextStyle(fontSize: 12, color: Colors.red[600]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build quick actions section
  Widget _buildQuickActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚡ Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton(
                'Generate Report',
                Icons.assessment,
                Colors.blue,
                _generateSecurityReport,
              ),
              _buildActionButton(
                'Export Data',
                Icons.download,
                Colors.green,
                _exportDashboardData,
              ),
              _buildActionButton(
                'Threat Hunt',
                Icons.search,
                Colors.orange,
                _startThreatHunting,
              ),
              _buildActionButton(
                'Incident Log',
                Icons.history,
                Colors.purple,
                _viewIncidentLog,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build action button
  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  // Action methods
  void _toggleMonitoring() {
    setState(() {
      if (_isMonitoring) {
        _idsController.stopMonitoring();
        _isMonitoring = false;
      } else {
        _idsController.startMonitoring();
        _isMonitoring = true;
      }
    });
    
    _refreshDashboard();
  }
  
  void _refreshDashboard() {
    setState(() {
      _threatStatus = _idsController.getThreatStatus();
      _detailedReport = _idsController.getDetailedThreatReport();
    });
  }
  
  void _showSettings() {
    // TODO: Implement dashboard settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dashboard settings coming soon')),
    );
  }
  
  void _showThreatDetails(String threat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Threat Details'),
        content: Text('Detailed information for: $threat'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _activateIncidentResponse() {
    // TODO: Implement incident response activation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Incident Response activated'),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  void _generateSecurityReport() {
    // TODO: Implement security report generation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating security report...')),
    );
  }
  
  void _exportDashboardData() {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting dashboard data...')),
    );
  }
  
  void _startThreatHunting() {
    // TODO: Implement threat hunting
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting threat hunting...')),
    );
  }
  
  void _viewIncidentLog() {
    // TODO: Implement incident log view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening incident log...')),
    );
  }
  
  String _getLastScanTime() {
    final lastScan = _threatStatus['last_scan'];
    if (lastScan == null) return 'Never';
    
    try {
      final scanTime = DateTime.parse(lastScan);
      final now = DateTime.now();
      final difference = now.difference(scanTime);
      
      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      return '${difference.inDays}d ago';
    } catch (e) {
      return 'Unknown';
    }
  }
}
