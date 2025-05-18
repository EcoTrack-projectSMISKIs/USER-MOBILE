// // lib/services/plug_service.dart

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class PlugService {
//   static final String baseUrl = '${dotenv.env['BASE_URL']}/api/plugs'; // UPDATE your IP

//   Future<List<dynamic>> getAllPlugs() async {
//     final response = await http.get(Uri.parse(baseUrl));
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to load plugs');
//     }
//   }

//   Future<Map<String, dynamic>> addPlug(String name, String ip, String userId) async {
//     final response = await http.post(Uri.parse(baseUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'name': name, 'ip': ip, 'user': userId}));

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to add plug');
//     }
//   }

//   Future<Map<String, dynamic>> connectPlugToUser(String userId, String plugId) async {
//     final response = await http.post(Uri.parse('$baseUrl/connect'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'userId': userId, 'plugId': plugId}));

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to connect plug');
//     }
//   }

//   Future<Map<String, dynamic>> getPlugStatus(String plugId) async {
//     final response = await http.get(Uri.parse('$baseUrl/$plugId/status'));
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to get plug status');
//     }
//   }

//   Future<Map<String, dynamic>> updatePlugName(String plugId, String newName) async {
//     final response = await http.put(Uri.parse('$baseUrl/$plugId'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'name': newName}));

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to update plug');
//     }
//   }
// }
