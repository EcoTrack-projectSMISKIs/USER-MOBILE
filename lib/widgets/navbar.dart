import 'package:ecotrack_mobile/screens/features/add_new_device.dart';
import 'package:ecotrack_mobile/screens/features/appliances.dart';
//import 'package:ecotrack_mobile/screens/features/dashboard.dart'; - luis' code where plug can be controlled and energy consumption data can be fetched
import 'package:ecotrack_mobile/screens/features/home_page.dart';
import 'package:ecotrack_mobile/screens/features/profile_settings.dart';
import 'package:ecotrack_mobile/screens/features/main_dashboard.dart';
import 'package:ecotrack_mobile/screens/add_plug/list_of_plugs.dart';
import 'package:ecotrack_mobile/screens/add_plug/tasmota_scanner_ios.dart';
import 'package:ecotrack_mobile/screens/add_plug/platform_specific.dart';
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
        targetPage = PlatformSpecificScanner();
        break;
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

  Widget _buildNavItem(BuildContext context, String iconPath, String activeIconPath, String label, int index) {
    final isActive = selectedIndex == index;
    final color = isActive ? Colors.green : Colors.grey;
    final imagePath = isActive ? activeIconPath : iconPath;

    return GestureDetector(
      onTap: () => _handleTap(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            width: 32,
            height: 32,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: "Proxima Nova")),
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
          _buildNavItem(
            context, 
            'assets/navbarlogos/dashboard.png', 
            'assets/navbarlogos/dashboard_g.png', 
            'Dashboard', 
            0
          ),
          _buildNavItem(
            context, 
            'assets/navbarlogos/plug.png', 
            'assets/navbarlogos/plug_g.png', 
            'Appliances', 
            1
          ),
          _buildNavItem(
            context, 
            'assets/navbarlogos/add.png', 
            'assets/navbarlogos/add_g.png', 
            'Add Device', 
            2
          ),
          _buildNavItem(
            context, 
            'assets/navbarlogos/news.png', 
            'assets/navbarlogos/news_g.png', 
            'Updates', 
            3
          ),
          _buildNavItem(
            context, 
            'assets/navbarlogos/settings.png', 
            'assets/navbarlogos/settings.png', 
            'Settings', 
            4
          ),
        ],
      ),
    );
  }
}