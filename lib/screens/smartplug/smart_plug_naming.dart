import 'package:ecotrack_mobile/screens/features/dashboard.dart';
import 'package:flutter/material.dart';

class SmartPlugNamingPage extends StatefulWidget {
  const SmartPlugNamingPage({super.key});

  @override
  State<SmartPlugNamingPage> createState() => _SmartPlugNamingPageState();
}

class _SmartPlugNamingPageState extends State<SmartPlugNamingPage> {
  final TextEditingController applianceController = TextEditingController();
  final List<String> suggestions = ["Refrigerator", "TV", "Air Conditioner"];

  void selectSuggestion(String name) {
    applianceController.text = name;
  }

  void finishSetup() {
    if (applianceController.text.isNotEmpty) {
      // Navigate to dashboard (HomePage) after successful naming
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const EnergyDashboard()),
        (route) => false, // Clear navigation stack
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an appliance name.")),
      );
    }
  }

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
            _buildProgressStep(currentStep: 2),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Name Your Device", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "TP-Link Kasa Smart Plug",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("Connected", style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: applianceController,
                    decoration: InputDecoration(
                      hintText: "Enter appliance name",
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.green),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.green),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("SUGGESTIONS:", style: TextStyle(color: Colors.black45)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: suggestions.map((s) {
                      return GestureDetector(
                        onTap: () => selectSuggestion(s),
                        child: Chip(
                          label: Text(s),
                          backgroundColor: Colors.grey.shade200,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: finishSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Continue", style: TextStyle(fontSize: 16)),
              ),
            )
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
