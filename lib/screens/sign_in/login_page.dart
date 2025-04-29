import 'package:ecotrack_mobile/screens/features/dashboard.dart';
import 'package:ecotrack_mobile/screens/features/home_page.dart';
import 'package:ecotrack_mobile/screens/forgot_password_page.dart';
import 'package:ecotrack_mobile/screens/landing_page/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String identifier = '';
  String password = '';
  bool rememberMe = true;
  bool obscureText = true;

  Future<void> login() async {
    final url = Uri.parse('${dotenv.env['BASE_URL']}/api/auth/mobile/login');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "identifier": identifier,
        "password": password,
      }),
    );

    final resData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final token = resData['token'];
      final user = resData['user'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token ?? '');
      await prefs.setString('userId', user['_id'] ?? ''); // new added
      await prefs.setString('name', user['name'] ?? '');
      await prefs.setString('username', user['username'] ?? '');
      await prefs.setString('email', user['email'] ?? '');
      await prefs.setString('phone', user['phone'] ?? '');
      await prefs.setString('barangay', user['barangay'] ?? '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resData['msg'] ?? "Login successful")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EnergyDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resData['msg'] ?? "Login failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.green),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LandingPage()),
                );
              },
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Sign in",
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Welcome to Ecotrack",
                          style:
                              TextStyle(fontSize: 14, color: Colors.black54)),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Email / Username / Phone",
                              border: UnderlineInputBorder(),
                            ),
                            onChanged: (val) => identifier = val,
                            validator: (val) =>
                                val!.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            obscureText: obscureText,
                            decoration: InputDecoration(
                              labelText: "Password",
                              border: const UnderlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscureText = !obscureText;
                                  });
                                },
                              ),
                            ),
                            onChanged: (val) => password = val,
                            validator: (val) =>
                                val!.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 16),
                          CheckboxListTile(
                            value: rememberMe,
                            activeColor: Colors.green,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) =>
                                setState(() => rememberMe = val ?? true),
                            title: const Text("Remember password"),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  login();
                                }
                              },
                              child: const Text("Continue",
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordPage()),
                              );
                            },
                            child: const Text("Forgot password?"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
