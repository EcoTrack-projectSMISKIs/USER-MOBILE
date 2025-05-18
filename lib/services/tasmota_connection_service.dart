import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TasmotaDevice {
  final String id;
  final String name;
  final String ipAddress;
  bool isOn;
  double powerUsage; // in watts
  
  TasmotaDevice({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.isOn = false,
    this.powerUsage = 0.0,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipAddress': ipAddress,
      'isOn': isOn,
      'powerUsage': powerUsage,
    };
  }
  
  factory TasmotaDevice.fromJson(Map<String, dynamic> json) {
    return TasmotaDevice(
      id: json['id'],
      name: json['name'],
      ipAddress: json['ipAddress'],
      isOn: json['isOn'] ?? false,
      powerUsage: json['powerUsage']?.toDouble() ?? 0.0,
    );
  }
}

class TasmotaConnectionService {
  // Singleton pattern
  static final TasmotaConnectionService _instance = TasmotaConnectionService._internal();
  factory TasmotaConnectionService() => _instance;
  TasmotaConnectionService._internal();
  
  final List<TasmotaDevice> _devices = [];
  final _devicesStreamController = StreamController<List<TasmotaDevice>>.broadcast();
  
  Stream<List<TasmotaDevice>> get devicesStream => _devicesStreamController.stream;
  List<TasmotaDevice> get devices => List.unmodifiable(_devices);
  
  // Initialize service and load saved devices
  Future<void> initialize() async {
    await _loadSavedDevices();
    // Start periodic status updates
    Timer.periodic(const Duration(minutes: 1), (_) {
      _updateAllDeviceStatuses();
    });
  }
  
  // Load devices from SharedPreferences
  Future<void> _loadSavedDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDevicesJson = prefs.getStringList('tasmota_devices') ?? [];
      
      _devices.clear();
      for (final deviceJson in savedDevicesJson) {
        final Map<String, dynamic> deviceMap = jsonDecode(deviceJson);
        _devices.add(TasmotaDevice.fromJson(deviceMap));
      }
      
      _devicesStreamController.add(_devices);
    } catch (e) {
      print('Error loading saved devices: $e');
    }
  }
  
  // Save devices to SharedPreferences
  Future<void> _saveDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> deviceJsonList = _devices
          .map((device) => jsonEncode(device.toJson()))
          .toList();
      
      await prefs.setStringList('tasmota_devices', deviceJsonList);
    } catch (e) {
      print('Error saving devices: $e');
    }
  }
  
  // Add a new Tasmota device
  Future<bool> addDevice(String name, String ipAddress) async {
    try {
      // Check if device is reachable and is a Tasmota device
      final isValid = await _validateTasmotaDevice(ipAddress);
      if (!isValid) {
        return false;
      }
      
      final String id = DateTime.now().millisecondsSinceEpoch.toString();
      final device = TasmotaDevice(
        id: id,
        name: name,
        ipAddress: ipAddress,
      );
      
      // Get initial status
      await _updateDeviceStatus(device);
      
      _devices.add(device);
      _devicesStreamController.add(_devices);
      await _saveDevices();
      return true;
    } catch (e) {
      print('Error adding device: $e');
      return false;
    }
  }
  
  // Remove a device
  Future<void> removeDevice(String id) async {
    _devices.removeWhere((device) => device.id == id);
    _devicesStreamController.add(_devices);
    await _saveDevices();
  }
  
  // Toggle device power
  Future<bool> togglePower(String id) async {
    try {
      final deviceIndex = _devices.indexWhere((device) => device.id == id);
      if (deviceIndex == -1) return false;
      
      final device = _devices[deviceIndex];
      final newState = !device.isOn;
      
      final response = await http.get(
        Uri.parse('http://${device.ipAddress}/cm?cmnd=Power%20${newState ? 'On' : 'Off'}'),
      );
      
      if (response.statusCode == 200) {
        // Update local state
        device.isOn = newState;
        _devicesStreamController.add(_devices);
        await _saveDevices();
        return true;
      }
      return false;
    } catch (e) {
      print('Error toggling power: $e');
      return false;
    }
  }
  
  // Update status of all devices
  Future<void> _updateAllDeviceStatuses() async {
    for (final device in _devices) {
      await _updateDeviceStatus(device);
    }
    _devicesStreamController.add(_devices);
    await _saveDevices();
  }
  
  // Update a single device's status
  Future<void> _updateDeviceStatus(TasmotaDevice device) async {
    try {
      // Get power state
      final powerResponse = await http.get(
        Uri.parse('http://${device.ipAddress}/cm?cmnd=Power'),
      ).timeout(const Duration(seconds: 5));
      
      if (powerResponse.statusCode == 200) {
        final powerData = jsonDecode(powerResponse.body);
        if (powerData.containsKey('POWER')) {
          device.isOn = powerData['POWER'] == 'ON';
        }
      }
      
      // Get power usage (if supported)
      final statusResponse = await http.get(
        Uri.parse('http://${device.ipAddress}/cm?cmnd=Status%208'),
      ).timeout(const Duration(seconds: 5));
      
      if (statusResponse.statusCode == 200) {
        final statusData = jsonDecode(statusResponse.body);
        if (statusData.containsKey('StatusSNS') && 
            statusData['StatusSNS'].containsKey('ENERGY')) {
          device.powerUsage = statusData['StatusSNS']['ENERGY']['Power']?.toDouble() ?? 0.0;
        }
      }
    } catch (e) {
      // Device might be offline, but we don't update the state
      print('Error updating device status: $e');
    }
  }
  
  // Validate if the IP address belongs to a Tasmota device
  Future<bool> _validateTasmotaDevice(String ipAddress) async {
    try {
      final response = await http.get(
        Uri.parse('http://$ipAddress/cm?cmnd=Status%200'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check if this is a Tasmota device by looking for typical Tasmota JSON structure
        return data.containsKey('Status') && 
               data['Status'].containsKey('FriendlyName');
      }
      return false;
    } catch (e) {
      print('Error validating Tasmota device: $e');
      return false;
    }
  }
  
  // Cleanup resources
  void dispose() {
    _devicesStreamController.close();
  }
}