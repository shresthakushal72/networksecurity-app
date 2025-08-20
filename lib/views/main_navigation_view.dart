import 'package:flutter/material.dart';
import 'wifi_scanner_view.dart';
import 'local_network_scanner_view.dart';

/// Main navigation view with drawer containing WiFi Scanner and Local Network Scanner
class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const WiFiScannerView(),
    const LocalNetworkScannerView(),
  ];

  final List<String> _pageTitles = [
    'WiFi Scanner',
    'Local Network Scanner',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAppInfo(context),
            tooltip: 'App Information',
          ),
        ],
      ),
      drawer: _buildNavigationDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.wifi_find),
            label: 'WiFi Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.network_check),
            label: 'Network Scanner',
          ),
        ],
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }

  /// Build navigation drawer
  Widget _buildNavigationDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Drawer header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue[600],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[600]!,
                  Colors.blue[800]!,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.security,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Network Security',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'WiFi & Network Scanner',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.wifi_find,
                  title: 'WiFi Scanner',
                  subtitle: 'Scan and analyze WiFi networks',
                  isSelected: _selectedIndex == 0,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.network_check,
                  title: 'Local Network Scanner',
                  subtitle: 'Scan devices on your network',
                  isSelected: _selectedIndex == 1,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                    Navigator.pop(context);
                  },
                ),
                const Divider(height: 32),
                _buildDrawerItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App information and help',
                  onTap: () {
                    Navigator.pop(context);
                    _showAppInfo(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'App configuration',
                  onTap: () {
                    Navigator.pop(context);
                    _showSettings(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual drawer item
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: Colors.blue[200]!, width: 1)
            : null,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[100] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.blue[700] : Colors.grey[700],
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.blue[800] : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.blue[600] : Colors.grey[600],
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  /// Show app information dialog
  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.security, color: Colors.blue),
              SizedBox(width: 8),
              Text('Network Security App'),
            ],
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This app is for educational purposes only. Network security is complex and cannot be fully automated.'),
                SizedBox(height: 16),
                Text('Features:'),
                SizedBox(height: 8),
                Text('• 🔍 WiFi Network Scanning'),
                Text('• 🔒 Security Analysis (WPS, Encryption, etc.)'),
                Text('• 📱 Local Network Device Discovery'),
                Text('• ⚠️ Risk Assessment'),
                Text('• 💡 Security Recommendations'),
                SizedBox(height: 16),
                Text('Always verify your network security and consult professionals when needed.'),
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

  /// Show settings dialog
  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.settings, color: Colors.grey),
              SizedBox(width: 8),
              Text('Settings'),
            ],
          ),
          content: const Text(
            'Settings will be available in future updates.\n\n'
            'For now, ensure you have:\n'
            '• WiFi enabled\n'
            '• Location Services enabled\n'
            '• Location permission granted to this app',
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
