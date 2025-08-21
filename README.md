# 🔒 Network Security Scanner

A comprehensive Flutter application for WiFi security analysis and local network device scanning. Built with clean MVC architecture for easy maintenance and future development.

## 🚀 Features

### WiFi Security Scanner
- **WPS Detection**: Identifies if WiFi Protected Setup is enabled and which version
- **Security Analysis**: Comprehensive assessment of network security including:
  - Encryption strength (WEP, WPA, WPA2, WPA3)
  - Channel security (2.4G vs 5G vs 6G)
  - Hidden network detection
  - Enterprise network identification
- **Risk Assessment**: Calculates security score and provides actionable recommendations
- **Auto-scanning**: Automatically scans when WiFi and Location permissions are granted

### Local Network Scanner
- **Device Discovery**: Finds all devices connected to your local network
- **Port Scanning**: Identifies open ports and running services on each device
- **Device Fingerprinting**: Determines device types (Router, Camera, Printer, etc.)
- **Security Analysis**: Assesses risk levels for each discovered device
- **MAC Address Discovery**: Attempts to get real MAC addresses from ARP tables

## 🏗️ Project Structure (MVC Pattern)

```
lib/
├── main.dart                          # App entry point
├── models/                            # Data models
│   ├── wifi_network.dart             # WiFi network data structure
│   ├── network_device.dart           # Network device data structure
│   └── security_analysis.dart        # Security analysis results
├── controllers/                       # Business logic
│   ├── wifi_scanner_controller.dart  # WiFi scanning logic
│   ├── network_scanner_controller.dart # Local network scanning
│   └── security_analysis_controller.dart # Security analysis logic
└── views/                            # UI components
    ├── main_navigation_view.dart     # Main navigation with drawer
    ├── wifi_scanner_view.dart        # WiFi scanning interface
    ├── local_network_scanner_view.dart # Local network scanning interface
    └── wifi_details_view.dart        # Detailed security analysis
```

## 🔧 How It Works

### 1. WiFi Scanning Process
```
User opens app → Check permissions → Auto-scan if available → Display networks → User selects network → Show security analysis
```

### 2. Local Network Scanning Process
```
User connects to WiFi → Navigate to Local Network Scanner → Initialize network info → Scan IP range → Port scan devices → Display results
```

### 3. Security Analysis Process
```
Select WiFi network → Analyze capabilities → Check WPS status → Assess encryption → Calculate security score → Provide recommendations
```

## 📱 User Interface

- **Navigation Drawer**: Easy access to different app sections
- **PortDroid-style Design**: Clean, professional interface
- **Pull-to-Refresh**: Intuitive WiFi scanning
- **Responsive Layout**: Works on all screen sizes
- **Toast Notifications**: User feedback for actions
- **Progress Indicators**: Real-time scanning status

## 🛡️ Security Features

### WPS Analysis
- **WPS 1.0**: High risk - vulnerable to brute force attacks
- **WPS 2.0+**: Low risk - rate limiting and lockout protection
- **Attack Methods**: Detailed explanation of possible vulnerabilities
- **Recommendations**: Actionable security advice

### Network Device Security
- **Risk Levels**: High (Red), Medium (Orange), Low (Green)
- **Device Types**: Automatic identification of cameras, printers, routers
- **Open Ports**: Detection of potentially vulnerable services
- **Security Advice**: Device-specific security recommendations

## 🚦 Getting Started

### Prerequisites
- Flutter SDK 3.7.2 or higher
- Android device or emulator
- WiFi connection for testing

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Connect your device
4. Run `flutter run`

### Required Permissions
- **Location Permission**: Required for WiFi scanning
- **WiFi State**: To access WiFi information
- **Network State**: For local network scanning

## 🔍 Code Quality Features

### For Beginner Developers
- **Clear Section Headers**: Each controller is organized into logical sections
- **Comprehensive Comments**: Every method explains what it does and why
- **Consistent Naming**: Methods and variables follow clear naming conventions
- **Error Handling**: Graceful handling of network and permission issues
- **Modular Design**: Easy to understand and modify individual components

### MVC Benefits
- **Separation of Concerns**: UI, logic, and data are clearly separated
- **Easy Testing**: Controllers can be tested independently
- **Maintainable Code**: Changes in one area don't affect others
- **Scalable Architecture**: Easy to add new features

## 🚀 Future Enhancements

### Planned Features
- **Real-time Monitoring**: Continuous network security monitoring
- **Vulnerability Database**: Updated security threat information
- **Network Topology**: Visual representation of network layout
- **Security Reports**: Exportable security assessments
- **Custom Scans**: User-defined scanning parameters

### Technical Improvements
- **State Management**: Integration with Provider or Riverpod
- **Database**: Local storage of scan results
- **Cloud Sync**: Backup and share security reports
- **API Integration**: Real-time security threat data

## 🐛 Troubleshooting

### Common Issues
1. **No WiFi Networks Found**: Check Location Services and WiFi permissions
2. **Scan Timeout**: Ensure stable WiFi connection
3. **Permission Denied**: Grant location permission in app settings
4. **No Local Devices**: Verify you're connected to a network

### Debug Mode
- Enable debug logging for detailed scan information
- Check console output for error messages
- Verify network connectivity and permissions

## 📚 Learning Resources

### Flutter Concepts Used
- **State Management**: Basic state management with setState
- **Async Programming**: Future and async/await patterns
- **Platform Channels**: Native Android functionality
- **Custom Widgets**: Reusable UI components
- **Navigation**: Drawer and bottom navigation

### Network Security Concepts
- **WPS Vulnerabilities**: Understanding WiFi Protected Setup risks
- **Port Scanning**: Identifying open services on devices
- **Device Fingerprinting**: Determining device types from network behavior
- **Security Scoring**: Quantifying network security levels

## 🤝 Contributing

This project is designed to be beginner-friendly. When contributing:
1. Follow the existing code structure
2. Add clear comments for complex logic
3. Test on real devices when possible
4. Update documentation for new features

## 📄 License

This project is for educational and security testing purposes. Always ensure you have permission to scan networks you don't own.

---

**Happy Coding! 🎉**

*Built with Flutter and a passion for network security* 
