import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roadies/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SquadMembersService {
  static const String baseUrl = 'http://$ip:8080/api/v1';

  static Future<void> joinSquad(int squadId, int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/members/join'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'squadId': squadId,
        'userId': userId,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('User joined squad successfully: ${responseData['message']}');
    } else {
      print('Failed to join squad: ${response.statusCode}');
    }
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  static Future<List<dynamic>> getUserSquads(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/members/user/$userId'));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['data'];
    } else {
      print('Failed to fetch squads: ${response.statusCode}');
      return [];
    }
  }

  static Future<List<dynamic>> getSquadMembers(int squadId) async {
    final response = await http.get(Uri.parse('$baseUrl/members/squad/$squadId'));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['data'];
    } else {
      print('Failed to fetch squad members: ${response.statusCode}');
      return [];
    }
  }
}
