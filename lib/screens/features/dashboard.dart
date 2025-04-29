import 'package:ecotrack_mobile/widgets/navbar.dart';
import 'package:flutter/material.dart';


class EnergyDashboard extends StatefulWidget {
  const EnergyDashboard({Key? key}) : super(key: key);

  @override
  State<EnergyDashboard> createState() => _EnergyDashboardState();
}

class _EnergyDashboardState extends State<EnergyDashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Handle navigation logic here if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Main Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EFFE),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          // Appliance circles layout
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              _buildApplianceCircle(
                                'AC',
                                Colors.green.shade700,
                                150,
                                hasIcon: true,
                                powerConsumption: '2,982 W',
                              ),
                              Positioned(
                                left: 40,
                                top: 50,
                                child: _buildApplianceCircle(
                                  'Other',
                                  Colors.grey.shade400,
                                  80,
                                ),
                              ),
                              Positioned(
                                left: 70,
                                bottom: 20,
                                child: _buildApplianceCircle(
                                  'Fan',
                                  Colors.lightGreen.shade300,
                                  100,
                                ),
                              ),
                              Positioned(
                                right: 70,
                                bottom: 20,
                                child: _buildApplianceCircle(
                                  'Ref',
                                  Colors.green.shade500,
                                  100,
                                ),
                              ),
                              Positioned(
                                right: 40,
                                top: 100,
                                child: _buildApplianceCircle(
                                  'Oven',
                                  Colors.lightGreen.shade400,
                                  100,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Energy consumption stats
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.power_outlined,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                'Today',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                '69 kWh',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const VerticalDivider(
                                    color: Colors.white,
                                    thickness: 1,
                                    width: 1,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.bolt,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                'This Week',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                '691 kWh',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // AI Energy Saving Tip
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Energy Saving Tip',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                              children: [
                                TextSpan(text: 'Based on your top appliance consumer, '),
                                TextSpan(
                                  text: 'AC',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ', which is used for '),
                                TextSpan(
                                  text: '69 hours daily',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ', you must save your energy'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // 👇 Use custom bottom navigation bar
          CustomBottomNavBar(
            selectedIndex: 0,
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
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (hasIcon) ...[
              const SizedBox(height: 4),
              const Icon(
                Icons.ac_unit,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 4),
              if (powerConsumption != null)
                Text(
                  powerConsumption,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
