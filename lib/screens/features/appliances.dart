import 'package:ecotrack_mobile/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:ecotrack_mobile/screens/features/dashboard.dart'; 

class AppliancesPage extends StatelessWidget {
  const AppliancesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Appliances'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.ac_unit, color: Colors.blue),
            title: const Text('Aircon', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Usage: 10.5%'),
            trailing: const Text('85 kWh'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EnergyDashboard()),
              );
            },
          ),
          const Divider(),
        ],
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 12.0),
        child: CustomBottomNavBar(selectedIndex: 1),
      ),
    );
  }
}
