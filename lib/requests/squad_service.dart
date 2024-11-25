import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:roadies/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SquadService {
  static const String baseUrl = 'http://$ip:8080/api/v1';

  // Method to create a squad
  static Future<void> createSquad(Map<String, dynamic> squadData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/squad'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(squadData),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body)['data'];
      await _saveSquadInfo(responseData);
      debugPrint('Squad created successfully');
    } else {
      debugPrint('Failed to create squad: ${response.statusCode}');
    }
  }

  // Method to get a squad by ID
  static Future<Map<String, dynamic>?> getSquad(int squadId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/squad/$squadId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      debugPrint('Failed to get squad: ${response.statusCode}');
      return null;
    }
  }

  // Method to update a squad
  static Future<void> updateSquad(
      int squadId, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('$baseUrl/squad/$squadId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body)['data'];
      await _saveSquadInfo(responseData);
      debugPrint('Squad updated successfully');
    } else {
      debugPrint('Failed to update squad: ${response.statusCode}');
    }
  }

  // Method to delete a squad
  static Future<void> deleteSquad(int squadId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/squad/$squadId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      debugPrint('Squad deleted successfully');
    } else {
      debugPrint('Failed to delete squad: ${response.statusCode}');
    }
  }

  // Private method to save squad information in SharedPreferences
  static Future<void> _saveSquadInfo(Map<String, dynamic> squadInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('squadId', squadInfo['id']);
    await prefs.setString('squadName', squadInfo['squadName']);
    await prefs.setString('squadDescription', squadInfo['squadDescription']);
    await prefs.setInt('squadCapacity', squadInfo['squadCapacity']);
    await prefs.setInt('squadRange', squadInfo['squadRange']);
  }
}
