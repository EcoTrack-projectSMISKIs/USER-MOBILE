import 'package:ecotrack_mobile/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EnergyDashboard extends StatefulWidget {
  const EnergyDashboard({Key? key}) : super(key: key);

  @override
  State<EnergyDashboard> createState() => _EnergyDashboardState();
}

class _EnergyDashboardState extends State<EnergyDashboard> {
  Map<String, dynamic> energy = {};
  bool isLoading = true;
  bool isOn = false;

  final String plugId = '681d8bee304eb26d6b987478'; // hardcoded

  @override
  void initState() {
    super.initState();
    fetchEnergyData();
  }

  Future<void> fetchEnergyData() async {
    try {
      final url =
          Uri.parse('${dotenv.env['BASE_URL']}/api/plugs/$plugId/status');
      final response = await http.get(url);
      print('Request URL: $url');

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fetchedEnergy = data['energy'];

        if (!mounted) return;
        setState(() {
          energy = fetchedEnergy ?? {};
          isOn = (energy['Power'] ?? 0) > 0;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load energy data');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> togglePlugPower() async {
    try {
      final url = isOn
          ? Uri.parse('${dotenv.env['BASE_URL']}/api/plugs/$plugId/off')
          : Uri.parse('${dotenv.env['BASE_URL']}/api/plugs/$plugId/on');

      final response = await http.post(url);

      print('Request URL: $url');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          isOn = !isOn; // Optimistically update UI
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isOn ? 'Plug turned ON' : 'Plug turned OFF')),
        );

        // Wait briefly before fetching updated energy status
        await Future.delayed(Duration(seconds: 1));
        fetchEnergyData();
      } else {
        throw Exception('Failed to toggle plug');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Energy Dashboard'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    _buildApplianceCircle(
                                      'AC',
                                      Colors.green.shade700,
                                      150,
                                      hasIcon: true,
                                      powerConsumption:
                                          '${energy['Power'] ?? 0} W',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: togglePlugPower,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isOn ? Colors.red : Colors.green,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 12),
                                  ),
                                  child: Text(isOn ? 'Turn Off' : 'Turn On'),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 6)
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Live Metrics',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  childAspectRatio: 3.5,
                                  children: [
                                    _buildMetricTile(
                                        'Power', '${energy['Power'] ?? 0} W'),
                                    _buildMetricTile('Apparent Power',
                                        '${energy['ApparentPower'] ?? 0} VA'),
                                    _buildMetricTile('Reactive Power',
                                        '${energy['ReactivePower'] ?? 0} VAR'),
                                    _buildMetricTile('Voltage',
                                        '${energy['Voltage'] ?? 0} V'),
                                    _buildMetricTile('Current',
                                        '${energy['Current'] ?? 0} A'),
                                    _buildMetricTile(
                                        'Factor', '${energy['Factor'] ?? 0}'),
                                    _buildMetricTile(
                                        'Today', '${energy['Today'] ?? 0} kWh'),
                                    _buildMetricTile(
                                        'Total', '${energy['Total'] ?? 0} kWh'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    color: Colors.black87, fontSize: 16),
                                children: [
                                  const TextSpan(text: 'Your AC is consuming '),
                                  TextSpan(
                                    text: '${energy['Power'] ?? 0} W',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const TextSpan(
                                      text:
                                          '. Consider reducing usage for savings.'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildApplianceCircle(String name, Color color, double size,
      {bool hasIcon = false, String? powerConsumption}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            if (hasIcon) ...[
              const SizedBox(height: 4),
              const Icon(Icons.ac_unit, color: Colors.white, size: 32),
              const SizedBox(height: 4),
              if (powerConsumption != null)
                Text(powerConsumption,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value) {
    return Row(
      children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500))),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
