import 'package:ecotrack_mobile/screens/features/dashboard.dart';
import 'package:ecotrack_mobile/screens/smartplug/smart_plug_failed.dart';
import 'package:ecotrack_mobile/screens/smartplug/smart_plug_naming.dart';
import 'package:flutter/material.dart';

class SmartPlugConnectPage extends StatelessWidget {
  const SmartPlugConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.green),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Connect Smart Plug",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            _buildProgressStep(currentStep: 1),
            const SizedBox(height: 24),
            _deviceCard("TP-Link Kasa Smart Plug", "Selected Device"),
            const SizedBox(height: 16),
            _instruction("Plug your device into a power outlet"),
            _instruction("Press and hold the power button for 5s until the LED starts blinking"),
            _instruction("Ensure your phone is connected to your home 2.4GHz Wi-Fi network"),
            _instruction("Press ‘Connect Now’ to continue"),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  bool success = true;
                  if (success) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SmartPlugNamingPage()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SmartPlugFailedPage()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Connect Now"),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const EnergyDashboard()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("I’ll Do This Later", style: TextStyle(color: Colors.green)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _instruction(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 10, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _deviceCard(String title, String subtitle) {
    return Container(
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

  Widget _buildProgressStep({required int currentStep}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isCurrent = index == currentStep;
        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: isCurrent ? Colors.green : Colors.grey[300],
                child: Text(
                  '${index + 1}',
                  style: TextStyle(color: isCurrent ? Colors.white : Colors.black),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                index == 0 ? "Select" : index == 1 ? "Connect" : "Name",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isCurrent ? Colors.green : Colors.black54,
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
