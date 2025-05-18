import 'package:flutter/material.dart';
import 'dart:io';
import 'package:ecotrack_mobile/screens/add_plug/tasmota_scanner_ios.dart';
import 'package:ecotrack_mobile/screens/add_plug/list_of_plugs.dart';

class PlatformSpecificScanner extends StatelessWidget {
  const PlatformSpecificScanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Return the appropriate scanner based on platform
    if (Platform.isAndroid) {
      return const TasmotaSmartPlugConnector();
    } else if (Platform.isIOS) {
      return const TasmotaSmartPlugScanneriOS();
    } else {
      // Fallback for other platforms
      return Scaffold(
        appBar: AppBar(title: const Text('Unsupported Platform')),
        body: const Center(
          child: Text('Tasmota scanner is only supported on Android and iOS'),
        ),
      );
    }
  }
}