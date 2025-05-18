import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class TasmotaSmartPlugScanneriOS extends StatefulWidget {
  const TasmotaSmartPlugScanneriOS({Key? key}) : super(key: key);

  @override
  _TasmotaSmartPlugScanneriOSState createState() => _TasmotaSmartPlugScanneriOSState();
}

class _TasmotaSmartPlugScanneriOSState extends State<TasmotaSmartPlugScanneriOS> {
  bool _isLoading = false;
  String _errorMessage = '';
  final TextEditingController _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Request location permission
    PermissionStatus status = await Permission.location.request();
    
    if (status.isPermanentlyDenied) {
      setState(() {
        _errorMessage = 'Location permission is permanently denied. Please enable it in app settings.';
      });
      
      // Show dialog to open settings
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'WiFi scanning requires location permission. Please enable location access in app settings.'
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: const Text('Open Settings'),
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    } else if (!status.isGranted) {
      setState(() {
        _errorMessage = 'Location permission is required to scan for WiFi networks';
      });
    }
  }

  void _openWifiSettings() async {
    // On iOS, we can only direct users to the Settings app
    if (Platform.isIOS) {
      // This URL scheme opens iOS WiFi settings
      final url = Uri.parse('App-Prefs:root=WIFI');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        // If the URL scheme doesn't work (Apple sometimes changes them),
        // provide manual instructions
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Connect to Tasmota'),
            content: const Text(
              'Please follow these steps:\n\n'
              '1. Open Settings\n'
              '2. Tap on Wi-Fi\n'
              '3. Connect to the Wi-Fi network starting with "tasmota_"\n'
              '4. Return to this app when connected'
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  void _connectManually() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManualConnectionPage(
          onDeviceConnected: (name, ipAddress) {
            // Handle the connected device
            Navigator.pop(context);
            // Here you would normally add the device to your list
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Connected to $name at $ipAddress')),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasmota Smart Plugs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkPermissions,
          ),
        ],
      ),
      // Wrap the entire body content in SingleChildScrollView for scrollability
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Permission Required',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_errorMessage),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _checkPermissions,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Connect to Tasmota Smart Plug',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'To connect to your Tasmota device on iOS:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Put your Tasmota device in setup mode\n'
                        '2. Connect to the Tasmota WiFi network\n'
                        '3. Return to this app to complete setup',
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.wifi),
                        label: const Text('Open WiFi Settings'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _openWifiSettings,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Already connected?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'If you\'re already connected to your Tasmota device\'s WiFi network, proceed with configuration:',
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.settings),
                        label: const Text('Configure Device'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WifiConfigPage(deviceName: 'Tasmota Device'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Manual Connection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'If you already know your Tasmota device\'s IP address, you can connect directly:',
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Connect Manually'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _connectManually,
                      ),
                    ],
                  ),
                ),
              ),
              // Add some bottom padding to ensure the last card is fully visible
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class ManualConnectionPage extends StatefulWidget {
  final Function(String name, String ipAddress) onDeviceConnected;
  
  const ManualConnectionPage({Key? key, required this.onDeviceConnected}) : super(key: key);

  @override
  _ManualConnectionPageState createState() => _ManualConnectionPageState();
}

class _ManualConnectionPageState extends State<ManualConnectionPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  bool _isValidating = false;
  String _error = '';

  Future<void> _validateAndConnect() async {
    final name = _nameController.text.trim();
    final ip = _ipController.text.trim();
    
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a name for your device');
      return;
    }
    
    if (ip.isEmpty) {
      setState(() => _error = 'Please enter the IP address');
      return;
    }
    
    // Basic IP validation
    final ipRegex = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');
    if (!ipRegex.hasMatch(ip)) {
      setState(() => _error = 'Please enter a valid IP address');
      return;
    }
    
    setState(() {
      _isValidating = true;
      _error = '';
    });
    
    try {
      // Here you would typically validate that the IP belongs to a Tasmota device
      // For demo purposes, we'll simulate a successful connection
      await Future.delayed(const Duration(seconds: 1));
      
      widget.onDeviceConnected(name, ip);
    } catch (e) {
      setState(() => _error = 'Failed to connect: ${e.toString()}');
    } finally {
      setState(() => _isValidating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Connection'),
      ),
      // Add scrollability to the manual connection page
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error, style: TextStyle(color: Colors.red.shade700)),
                ),
                
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Device Name',
                  hintText: 'e.g., Living Room Plug',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ipController,
                decoration: const InputDecoration(
                  labelText: 'IP Address',
                  hintText: 'e.g., 192.168.1.100',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isValidating ? null : _validateAndConnect,
                child: _isValidating 
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2)
                        ),
                        SizedBox(width: 8),
                        Text('Connecting...'),
                      ],
                    )
                  : const Text('Connect'),
              ),
              // Add some bottom padding to ensure the button is fully visible
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class WifiConfigPage extends StatelessWidget {
  final String deviceName;
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  WifiConfigPage({Key? key, required this.deviceName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configure $deviceName')),
      // Add scrollability to the WiFi config page
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WIFI CONFIGURATION',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _ssidController,
                        decoration: const InputDecoration(
                          labelText: 'Your WiFi Network SSID',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'WiFi Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // This would normally send the configuration to the device
                          // and then reconnect to the original network
                          Navigator.pop(context);
                        },
                        child: const Text('Connect Device to Network'),
                      ),
                      // Add some bottom padding
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              // Add some additional bottom padding to ensure everything is visible
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}