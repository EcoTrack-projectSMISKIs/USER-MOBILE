import 'package:ecotrack_mobile/widgets/navbar.dart';
import 'package:flutter/material.dart';

class AppliancesPage extends StatelessWidget {
  const AppliancesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appliances'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text('Appliances Page'),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 1),
    );
  }
}
