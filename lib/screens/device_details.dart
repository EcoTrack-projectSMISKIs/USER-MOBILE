import 'package:ecotrack_mobile/screens/device_usage_page.dart';
import 'package:flutter/material.dart';


class DeviceDetailsPage extends StatelessWidget {
  const DeviceDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text("Smart Meter Devices"),
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/profile_icon.png"),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "List of your devices",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildDeviceTile(context, "Television", true),
                  _buildDeviceTile(context, "Aircon", false),
                  _buildDeviceTile(context, "Electric Fan", true),
                  _buildDeviceTile(context, "Washing Machine", true),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.grey,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDeviceTile(BuildContext context, String name, bool isActive) {
    return ListTile(
      leading: Icon(
        Icons.circle,
        color: isActive ? Colors.green : Colors.red,
      ),
      title: Text(name, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeviceUsagePage(deviceName: name),
          ),
        );
      },
    );
  }
}
