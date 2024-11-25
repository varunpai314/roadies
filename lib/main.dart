import 'package:flutter/material.dart';
import 'package:roadies/pages/home_page.dart';
import 'package:roadies/pages/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  int? userId = await getUserId();
  runApp(MyApp(userId: userId));
}

Future<int?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('userId');
}

class MyApp extends StatelessWidget {
  final int? userId;

  const MyApp({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roadies',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: userId == null ? const RegisterPage() : const HomePage(),
    );
  }
}
