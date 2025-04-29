import 'package:ecotrack_mobile/screens/features/add_new_device.dart';
import 'package:ecotrack_mobile/screens/features/appliances.dart';
import 'package:ecotrack_mobile/screens/features/dashboard.dart';
import 'package:ecotrack_mobile/screens/features/home_page.dart';
import 'package:ecotrack_mobile/screens/features/profile_settings.dart';
import 'package:flutter/material.dart';


class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNavBar({Key? key, required this.selectedIndex}) : super(key: key);

  void _handleTap(BuildContext context, int index) {
    if (index == selectedIndex) return;

    Widget targetPage;
    switch (index) {
      case 0:
        targetPage = const EnergyDashboard();
        break;
      case 1:
        targetPage = const AppliancesPage();
        break;
      case 2:
        targetPage = const AddNewDevice();
      case 3:
        targetPage = const HomePage();
        break;
      case 4:
        targetPage = const ProfileSettingsPage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isActive = selectedIndex == index;
    final color = isActive ? Colors.green : Colors.grey;

    return GestureDetector(
      onTap: () => _handleTap(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(context, Icons.home, 'Dashboard', 0),
          _buildNavItem(context, Icons.power, 'Appliances', 1),
          _buildNavItem(context, Icons.add_circle, 'Add Device', 2),
          _buildNavItem(context, Icons.article_outlined, 'Updates', 3),
          _buildNavItem(context, Icons.settings, 'Settings', 4),
        ],
      ),
    );
  }
}
