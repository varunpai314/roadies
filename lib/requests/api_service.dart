import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:roadies/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadies/model/user.dart';

class ApiService {
  static const String baseUrl = 'http://$ip:8080/api/v1';

  static Future<void> createUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body)['data'];
      await _saveUserInfo(responseData);
      debugPrint('User created successfully');
    } else {
      debugPrint('Failed to create user: ${response.statusCode}');
    }
  }

  static Future<bool> login(String phoneNumber, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'phoneNumber': phoneNumber,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['message'] == 'success') {
        // Save user info to shared preferences
        Map<String, dynamic>? userInfo =
            await getUserInfo(responseData['data']);
        await _saveUserInfo(userInfo!);
        return true;
      }
    }
    return false;
  }

  static Future<Map<String, dynamic>?> getUserInfo(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['data'];
    } else {
      debugPrint('Failed to fetch user info: ${response.statusCode}');
      return null;
    }
  }

  static Future<void> updateUser(
      int userId, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/$userId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body)['data'];
      await _saveUserInfo(responseData);
      debugPrint('User updated successfully');
    } else {
      debugPrint('Failed to update user: ${response.statusCode}');
    }
  }

  static Future<void> _saveUserInfo(Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userInfo['id']);
    await prefs.setString('username', userInfo['name']);
    await prefs.setString('phoneNumber', userInfo['phone_number']);
    await prefs.setString('bio', userInfo['bio']);
  }
}
