import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;


class WiFiHelper {

  /// Enable or disable WiFi
  static Future<void> setWiFiEnabled(bool enable, {bool openSettings = false}) async {
    try {
      await WiFiForIoTPlugin.setEnabled(enable, shouldOpenSettings: openSettings);
      print('WiFi ${enable ? 'enabled' : 'disabled'}');
    } catch (e) {
      print('Error setting WiFi state: $e');
    }
  }

  /// Check if WiFi is currently enabled
  static Future<bool> isWiFiEnabled() async {
    try {
      return await WiFiForIoTPlugin.isEnabled();
    } catch (e) {
      print('Error checking WiFi state: $e');
      return false;
    }
  }

/*
  /// Force network traffic via WiFi
  /// Useful for IoT applications when communicating with a device
  static Future<bool> forceWiFiUsage(bool useWifi) async {
    try {
      return await WiFiForIoTPlugin.forceWifiUsage(useWifi);
    } catch (e) {
      print('Error forcing WiFi usage: $e');
      return false;
    }
  }

*/

  /// Connect to WiFi network with advanced options
  static Future<bool> connectToWiFi(
    String ssid, {
    String password = '',
    NetworkSecurity security = NetworkSecurity.NONE,
    bool forceRouting = false,
  }) async {
    try {
      // Request location permissions
      final permissionStatus = await Permission.location.request();
      if (!permissionStatus.isGranted) {
        print('Location permission denied');
        return false;
      }

      // Ensure WiFi is enabled
      await setWiFiEnabled(true);

      // Connect to WiFi
      bool connected = await WiFiForIoTPlugin.connect(
        ssid,
        password: password,
        security: _convertSecurityType(security),
        withInternet: false,
      );

      if (connected) {
        print('Successfully connected to WiFi: $ssid');

       /* 
        // Optionally force routing through this WiFi
        if (forceRouting) {
          await forceWiFiUsage(true);
        }
        */

        return true;
      } else {
        print('Failed to connect to WiFi: $ssid');
        return false;
      }
    } catch (e) {
      print('Error connecting to WiFi: $e');
      return false;
    }
  }

  // Convert custom security type to package-specific type
  static dynamic _convertSecurityType(NetworkSecurity security) {
    try {
      switch (security) {
        case NetworkSecurity.NONE:
          return NetworkSecurity.NONE;
        case NetworkSecurity.WPA:
          return NetworkSecurity.WPA;
        case NetworkSecurity.WEP:
          return NetworkSecurity.WEP;
        default:
          return NetworkSecurity.NONE;
      }
    } catch (e) {
      print('Error converting security type: $e');
      return null;
    }
  }

  // Remove a WiFi network
  static Future<bool> removeWifiNetwork(String ssid) async {
    try {
      await WiFiForIoTPlugin.removeWifiNetwork(ssid);
      return true;
    } catch (e) {
      print('Error removing WiFi network: $e');
      return false;
    }
  }

  // Get current SSID
  static Future<String?> getCurrentSSID() async {
    try {
      return await WiFiForIoTPlugin.getSSID();
    } catch (e) {
      print('Error getting current SSID: $e');
      return null;
    }
  }
}

class TasmotaSmartPlugConnector {
  // Method to connect to Tasmota plug's access point
  Future<bool> connectToTasmotaPlugAP(String ssid, {String password = ''}) async {
    try {
      // Ensure WiFi is enabled
      await WiFiHelper.setWiFiEnabled(true);

      // Attempt to connect to the Tasmota plug's network
      bool result = await WiFiHelper.connectToWiFi(
        ssid, 
        password: password, 
        security: NetworkSecurity.NONE,
        forceRouting: true, // Force routing through this WiFi
      );

      if (result) {
        print('Successfully connected to Tasmota plug network: $ssid');
        return true;
      } else {
        print('Failed to connect to Tasmota plug network: $ssid');
        return false;
      }
    } catch (e) {
      print('Error connecting to Tasmota plug: $e');
      return false;
    }
  }

  // Method to configure Tasmota plug with new WiFi credentials
  Future<bool> configureTasmotaPlug(String newSSID, String newPassword) async {
    try {
      // Prepare the URL for configuring WiFi credentials
      final encodedSSID = Uri.encodeComponent(newSSID);
      final encodedPassword = Uri.encodeComponent(newPassword);
      
      final configUrl = 'http://192.168.4.1/wi?s1=$encodedSSID&p1=$encodedPassword&save';

      // Attempt to send configuration to Tasmota plug
      final response = await http.get(
        Uri.parse(configUrl),
        headers: {
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        },
      );

      if (response.statusCode == 200) {
        print('Tasmota plug WiFi configuration sent successfully');
        print('Response: ${response.body}');
        
        /*
        // Disable forced WiFi usage after configuration
        await WiFiHelper.forceWiFiUsage(false);
        */ 


        return true;
      } else {
        print('Failed to configure Tasmota plug. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error configuring Tasmota plug: $e');
      return false;
    }
  }

  // Optional: Method to restart the Tasmota device
  Future<bool> restartDevice() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.4.1/cm?cmnd=Restart%201'),
      );

      if (response.statusCode == 200) {
        print('Tasmota plug restart command sent');
        return true;
      } else {
        print('Failed to send restart command. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error sending restart command: $e');
      return false;
    }
  }
}

class TasmotaPlugConfigScreen extends StatefulWidget {
  @override
  _TasmotaPlugConfigScreenState createState() => _TasmotaPlugConfigScreenState();
}

class _TasmotaPlugConfigScreenState extends State<TasmotaPlugConfigScreen> {
  final TasmotaSmartPlugConnector _plugConnector = TasmotaSmartPlugConnector();
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _statusMessage = 'Ready to configure';
  bool _isConfiguring = false;

  Future<void> _configureSmartPlug() async {
    // Validate inputs
    if (_ssidController.text.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter a WiFi network name';
      });
      return;
    }

    setState(() {
      _isConfiguring = true;
      _statusMessage = 'Connecting to Tasmota plug...';
    });

    try {
      // Ensure WiFi is enabled
      await WiFiHelper.setWiFiEnabled(true);

      // Connect to Tasmota plug's AP (typically an open network)
      bool connected = await _plugConnector.connectToTasmotaPlugAP('tasmota') ||
          await _plugConnector.connectToTasmotaPlugAP('ecotrack-plug');

      if (connected) {
        setState(() {
          _statusMessage = 'Connected to Tasmota plug. Configuring WiFi...';
        });

        // Configure with new WiFi credentials
        bool configured = await _plugConnector.configureTasmotaPlug(
          _ssidController.text, 
          _passwordController.text
        );

        if (configured) {
          // Optional: Send restart command
          await _plugConnector.restartDevice();

          setState(() {
            _statusMessage = 'Smart plug configured successfully!';
          });

          // Optionally remove the temporary WiFi network
          await WiFiHelper.removeWifiNetwork('tasmota');

          // Show success dialog
          _showConfigurationDialog(true, 'Smart plug configured successfully!');
        } else {
          setState(() {
            _statusMessage = 'Failed to configure smart plug';
          });
          
          // Show failure dialog
          _showConfigurationDialog(false, 'Failed to configure smart plug. Please try again.');
        }
      } else {
        setState(() {
          _statusMessage = 'Failed to connect to Tasmota plug';
        });
        
        // Show failure dialog
        _showConfigurationDialog(false, 'Could not connect to Tasmota plug. Ensure it is in AP mode.');
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
      });
      
      // Show error dialog
      _showConfigurationDialog(false, 'An unexpected error occurred: ${e.toString()}');
    } finally {
      setState(() {
        _isConfiguring = false;
      });

/*
      // Ensure WiFi routing is disabled after configuration
      await WiFiHelper.forceWiFiUsage(false);
        */

    }
  }

  // Method to show configuration result dialog
  void _showConfigurationDialog(bool isSuccess, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isSuccess ? 'Configuration Successful' : 'Configuration Failed',
            style: TextStyle(
              color: isSuccess ? Colors.green : Colors.red,
            ),
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Additional diagnostic method to check WiFi status
  Future<void> _checkWiFiStatus() async {
    bool isEnabled = await WiFiHelper.isWiFiEnabled();
    String? currentSSID = await WiFiHelper.getCurrentSSID();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'WiFi Enabled: $isEnabled\n'
          'Current SSID: ${currentSSID ?? "Not connected"}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasmota Plug WiFi Configuration'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.wifi),
            onPressed: _checkWiFiStatus,
            tooltip: 'Check WiFi Status',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Configure Tasmota Smart Plug',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Ensure the Tasmota plug is in Access Point (AP) mode before configuring.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _ssidController,
              decoration: InputDecoration(
                labelText: 'Home WiFi Network Name (SSID)',
                hintText: 'Enter your home WiFi network name',
                prefixIcon: Icon(Icons.wifi),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'WiFi Password',
                hintText: 'Enter your home WiFi password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isConfiguring ? null : _configureSmartPlug,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                disabledBackgroundColor: Colors.blue.shade200,
              ),
              child: _isConfiguring 
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Configure Smart Plug', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
            ),
            SizedBox(height: 20),
            Text(
              _statusMessage,
              style: TextStyle(
                color: _statusMessage.contains('Failed') 
                  ? Colors.red 
                  : _statusMessage.contains('successful') 
                    ? Colors.green 
                    : Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}