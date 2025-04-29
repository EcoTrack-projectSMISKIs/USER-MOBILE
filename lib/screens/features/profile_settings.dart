import 'package:ecotrack_mobile/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecotrack_mobile/screens/landing_page/landing_page.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({Key? key}) : super(key: key);

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  String name = "";
  String username = "";
  String email = "";
  String phone = "";
  String barangay = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? "Not Set";
      username = prefs.getString('username') ?? "Not Set";
      email = prefs.getString('email') ?? "Not Set";
      phone = prefs.getString('phone') ?? "Not Set";
      barangay = prefs.getString('barangay') ?? "Not Set";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Settings"),
        automaticallyImplyLeading: false, // removes the back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/profile_icon.png"),
            ),
            const SizedBox(height: 10),
            _buildProfileOption("Name", name),
            _buildProfileOption("Username", username),
            _buildProfileOption("Email Address", email),
            _buildProfileOption("Phone Number", phone),
            _buildProfileOption("Barangay", barangay),
            const SizedBox(height: 40),
            _buildLogoutButton(context),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(selectedIndex: 4),
    );
  }

  Widget _buildProfileOption(String title, String value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        // Add edit functionality if needed
        // functions to edit hereeeeeeeeeeeeeee, note
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LandingPage()),
          (Route<dynamic> route) => false,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        "Logout",
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}