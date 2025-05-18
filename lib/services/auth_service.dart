import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// do not remove comments for easy debugging
class AuthService {
  final String apiUrl = "http://192.168.1.11/api/auth"; // update with correct IP :)) mac ip ko
  // final String apiUrl = "http://192.168.1.9:5001/api/auth"; // update with correct IP :)) phone ko na ip

  // reg func
  Future<bool> registerWithDetails(String name, String username, String phone, String email, String password) async {
    final response = await http.post(
      Uri.parse("$apiUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "username": username,
        "phone": phone,
        "email": email,
        "password": password
      }),
    );

    return response.statusCode == 201;
  }

  // Lcan login withy email, username, or phone number
  Future<bool> loginWithIdentifier(String identifier, String password) async {
    final response = await http.post(
      Uri.parse("$apiUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"identifier": identifier, "password": password}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      String? token = responseData['token'];

      if (token != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('name', responseData['user']['name']);
        await prefs.setString('username', responseData['user']['username']);
        await prefs.setString('email', responseData['user']['email']);
        await prefs.setString('phone', responseData['user']['phone']);
        return true;
      }
    }
    return false;
  }

  // logout fun
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // toremove all stored user data
  }
}
