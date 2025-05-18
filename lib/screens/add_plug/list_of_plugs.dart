import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'dart:io';

class TasmotaSmartPlugConnector extends StatefulWidget {
  const TasmotaSmartPlugConnector({Key? key}) : super(key: key);

  @override
  _TasmotaSmartPlugConnectorState createState() => _TasmotaSmartPlugConnectorState();
}

class _TasmotaSmartPlugConnectorState extends State<TasmotaSmartPlugConnector> {
  // Specific list of smart plug SSIDs in AP mode
  static const List<String> _PLUG_AP_SSIDS = ['tasmota', 'ecotrack-plug'];
  
  // WiFi scan related variables
  List<WiFiAccessPoint> _accessPoints = <WiFiAccessPoint>[];
  StreamSubscription<List<WiFiAccessPoint>>? _subscription;
  bool _isScanning = false;
  String _statusMessage = "Ready to scan smart plug networks";

  // Connection state variables
  String? _connectingToSSID;
  final TextEditingController _homeWifiSsidController = TextEditingController();
  final TextEditingController _homeWifiPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkWiFiScanCapabilities();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _homeWifiSsidController.dispose();
    _homeWifiPasswordController.dispose();
    super.dispose();
  }

  // Check if WiFi scanning is possible
  Future<void> _checkWiFiScanCapabilities() async {
    // Request necessary permissions
    await [
      Permission.location,
      Permission.nearbyWifiDevices,
    ].request();

    final canStartScan = await WiFiScan.instance.canStartScan();
    final canGetResults = await WiFiScan.instance.canGetScannedResults();

    if (canStartScan != CanStartScan.yes || canGetResults != CanGetScannedResults.yes) {
      _showErrorDialog(
        "WiFi Scanning Unavailable", 
        "Unable to scan for smart plug networks. Check your device's WiFi and location permissions."
      );
    }
  }

  // Scan for smart plug networks
  Future<void> _scanForSmartPlugs() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _statusMessage = "Scanning for smart plug networks...";
      _accessPoints = [];
    });

    try {
      // Start WiFi scan
      await WiFiScan.instance.startScan();
      
      // Get scanned results
      final results = await WiFiScan.instance.getScannedResults();
      
      setState(() {
        // Filter only Tasmota and Ecotrack plug networks
        _accessPoints = results.where((ap) => 
          _PLUG_AP_SSIDS.any((plugSsid) => 
            ap.ssid.toLowerCase().contains(plugSsid.toLowerCase())
          )
        ).toList();

        _isScanning = false;
        _statusMessage = _accessPoints.isEmpty 
          ? "No smart plug networks found" 
          : "${_accessPoints.length} smart plug network(s) detected";
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusMessage = "Scan error: $e";
      });
    }
  }

  // Show configuration dialog for smart plug
  Future<void> _showSmartPlugConfigDialog(WiFiAccessPoint plugAccessPoint) async {
    // Scan for home WiFi networks
    List<WiFiAccessPoint> homeNetworks = [];
    try {
      await WiFiScan.instance.startScan();
      homeNetworks = await WiFiScan.instance.getScannedResults();
      // Filter out the plug's own network
      homeNetworks = homeNetworks.where((network) => 
        !_PLUG_AP_SSIDS.any((plugSsid) => 
          network.ssid.toLowerCase().contains(plugSsid.toLowerCase())
        )
      ).toList();
    } catch (e) {
      print('Error scanning home networks: $e');
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // State to manage network selection
        return StatefulBuilder(
          builder: (context, setState) {
            WiFiAccessPoint? selectedNetwork;

            return AlertDialog(
              title: Text('Configure ${plugAccessPoint.ssid}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Select your home WiFi network:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    
                    // WiFi Network List
                    Container(
                      height: 200,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: homeNetworks.isEmpty
                          ? const Center(
                              child: Text(
                                'No networks found. Please check your WiFi.',
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: homeNetworks.length,
                              itemBuilder: (context, index) {
                                final network = homeNetworks[index];
                                return ListTile(
                                  title: Text(network.ssid),
                                  leading: Icon(
                                    selectedNetwork == network 
                                      ? Icons.radio_button_checked 
                                      : Icons.radio_button_unchecked,
                                    color: Colors.blue,
                                  ),
                                  trailing: Text(
                                    '${network.level} dBm',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedNetwork = network;
                                      _homeWifiSsidController.text = network.ssid;
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Manual SSID Input
                    TextField(
                      controller: _homeWifiSsidController,
                      decoration: const InputDecoration(
                        labelText: 'WiFi Network',
                        hintText: 'Type or Select your WiFi Network',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Password Input
                    TextField(
                      controller: _homeWifiPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'WiFi Password',
                        hintText: 'Enter your WiFi Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Configure Plug'),
                  onPressed: () {
                    // Validate inputs
                    if (_homeWifiSsidController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select or enter a WiFi network'))
                      );
                      return;
                    }
                    
                    Navigator.of(context).pop();
                    _configureSmartPlug(
                      plugAccessPoint, 
                      _homeWifiSsidController.text.trim(), 
                      _homeWifiPasswordController.text.trim()
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Configure smart plug with home WiFi credentials
  Future<void> _configureSmartPlug(
    WiFiAccessPoint plugAccessPoint, 
    String homeWifiSsid, 
    String homeWifiPassword
  ) async {
    try {
      // Encode SSID and password to handle special characters
      final encodedSsid = Uri.encodeComponent(homeWifiSsid);
      final encodedPassword = Uri.encodeComponent(homeWifiPassword);

      // Construct the URL with credentials
      final configUrl = 'http://192.168.4.1/wi?s1=$encodedSsid&p1=$encodedPassword&save';
      
      // Attempt to send configuration to Tasmota plug
      final response = await http.get(Uri.parse(configUrl)); // not sure of post or get

      if (response.statusCode == 200) {
        _showSuccessDialog(
          "Configuration Successful", 
          "Smart plug ${plugAccessPoint.ssid} has been configured to connect to $homeWifiSsid"
        );
      } else {
        _showErrorDialog(
          "Configuration Failed", 
          "Unable to configure plug. Status code: ${response.statusCode}"
        );
      }
    } catch (e) {
      _showErrorDialog(
        "Configuration Error", 
        "An error occurred while configuring the smart plug: $e"
      );
    }
  }

  // Helper method to show success dialog
  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Helper method to show error dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Plug Configurator'),
      ),
      body: Column(
        children: [
          // Status and scanning information
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: $_statusMessage',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scanning for: ${_PLUG_AP_SSIDS.join(", ")} networks',
                ),
              ],
            ),
          ),

          // List of detected smart plug networks
          Expanded(
            child: _accessPoints.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off, 
                          size: 100, 
                          color: Colors.grey.shade300
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isScanning 
                            ? 'Searching for smart plug networks...' 
                            : 'No smart plug networks found',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _accessPoints.length,
                    itemBuilder: (context, index) {
                      final plugAp = _accessPoints[index];
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Icon(
                            Icons.electrical_services, 
                            color: plugAp.level > -70 
                                ? Colors.green 
                                : plugAp.level > -80 
                                    ? Colors.orange 
                                    : Colors.red,
                          ),
                          title: Text(plugAp.ssid),
                          subtitle: Text('Signal: ${plugAp.level} dBm'),
                          trailing: ElevatedButton(
                            onPressed: () => _showSmartPlugConfigDialog(plugAp),
                            child: const Text('Configure'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isScanning ? null : _scanForSmartPlugs,
        tooltip: 'Scan for Smart Plugs',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}