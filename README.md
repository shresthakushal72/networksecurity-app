# WiFi Scanner App

A Flutter application that scans for available WiFi networks and displays them sorted by signal strength.

## Features

- **WiFi Network Scanning**: Automatically detects nearby WiFi networks
- **Signal Strength Sorting**: Networks are displayed with strongest signal at the top
- **Visual Indicators**: Color-coded signal strength (Green = Excellent, Red = Poor)
- **Network Information**: Shows SSID, signal strength, security type, and frequency
- **Real-time Updates**: Live scanning with progress indicators

## How to Use

1. **Launch the App**: Open the WiFi Scanner app
2. **Grant Permissions**: Allow location and WiFi permissions when prompted
3. **Start Scanning**: Tap the "Scan for WiFi" button
4. **View Results**: Networks will appear sorted by signal strength
5. **Rescan**: Tap the scan button again to refresh the list

## Signal Strength Indicators

- 🟢 **Excellent** (-50 dBm and above): Strong signal, optimal performance
- 🟡 **Very Good** (-60 to -50 dBm): Good signal, reliable connection
- 🟡 **Good** (-70 to -60 dBm): Moderate signal, acceptable performance
- 🟠 **Fair** (-80 to -70 dBm): Weak signal, may have connectivity issues
- 🔴 **Poor** (Below -80 dBm): Very weak signal, unreliable connection

## Technical Details

- **Platform**: Android (minimum SDK 21)
- **Permissions Required**:
  - `ACCESS_FINE_LOCATION`
  - `ACCESS_COARSE_LOCATION`
  - `ACCESS_WIFI_STATE`
  - `CHANGE_WIFI_STATE`
  - `NEARBY_WIFI_DEVICES`

## Dependencies

- `wifi_scan: ^0.4.0+3` - WiFi scanning functionality
- `flutter` - UI framework

## Building and Running

1. Ensure you have Flutter SDK installed
2. Run `flutter pub get` to install dependencies
3. Connect an Android device or start an emulator
4. Run `flutter run` to build and launch the app

## Note

This app requires location permissions to scan for WiFi networks, as per Android security requirements. The app will only scan for networks and display information - it cannot connect to networks or access network passwords.
"# networksecurity-app" 
"# networksecurity-app" 
"# networksecurity-app" 
