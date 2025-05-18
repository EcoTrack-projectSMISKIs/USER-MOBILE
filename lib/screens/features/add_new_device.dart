import 'package:ecotrack_mobile/screens/smartplug/smart_plug_connect.dart';
import 'package:flutter/material.dart';


class AddNewDevice extends StatelessWidget {
  const AddNewDevice({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Add New Device.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text("Please select or add your smart plug device",
                style: TextStyle(color: Colors.black54), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Compatible Smart Plug Devices", style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 16),
            _plugOption("TP-Link Kasa Smart Plug", "Real-time energy monitoring", context),
            _plugOption("Sonoff S31 Smart Plug", "Power monitoring & scheduling", context),
            _plugOption("Tuya Smart Plug", "Energy usage tracking", context),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartPlugConnectPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Add New Smart Plug Device"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _plugOption(String title, String subtitle, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 20, backgroundColor: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          )
        ],
      ),
    );
  }
}