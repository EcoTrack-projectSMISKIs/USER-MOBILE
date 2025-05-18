import 'package:ecotrack_mobile/screens/smartplug/smart_plug_connect.dart';
import 'package:flutter/material.dart';


class SmartPlugFailedPage extends StatelessWidget {
  const SmartPlugFailedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.arrow_back, color: Colors.green),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Connect Smart Plug", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            _buildProgressStep(currentStep: 1),
            const SizedBox(height: 40),
            const Icon(Icons.error, size: 100, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              "Connection Failed",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Unable to connect to the smart plug.\nPlease ensure the device is in pairing mode and your Wi-Fi network is stable.",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SmartPlugConnectPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Try Again", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep({required int currentStep}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isCurrent = index == currentStep;
        final isFailed = currentStep == 1 && index == 1;
        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: isFailed
                    ? Colors.red
                    : (isCurrent ? Colors.green : Colors.grey[300]),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isFailed || isCurrent ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                index == 0 ? "Select" : index == 1 ? "Connect" : "Name",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isFailed
                      ? Colors.red
                      : (isCurrent ? Colors.green : Colors.black54),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}