import 'package:flutter/material.dart';
import 'package:roadies/requests/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadies/pages/register_page.dart'; // Make sure this import is correct

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _phoneNumber = '';
  String _bio = '';
  bool _isEditing = false; // Flag to toggle between display and edit mode

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
      _phoneNumber = prefs.getString('phoneNumber') ?? '';
      _bio = prefs.getString('bio') ?? '';
    });

    // Debugging print statements
    print('Loaded username: $_username');
    print('Loaded phone number: $_phoneNumber');
    print('Loaded bio: $_bio');
  }

  Future<void> _saveUserInfo() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId != null) {
        final userUpdates = {
          'username': _username,
          'bio': _bio,
          'phoneNumber': _phoneNumber,
        };

        await ApiService.updateUser(userId, userUpdates);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          setState(() {
            _isEditing = false; // Switch to display mode after saving
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile')),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all shared preferences

    // Navigate to the RegisterPage
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegisterPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          // Edit icon button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing =
                    !_isEditing; // Toggle between edit and display mode
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  // Username Field
                  _isEditing
                      ? TextFormField(
                          initialValue: _username,
                          decoration:
                              const InputDecoration(labelText: 'Username'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _username = value!;
                          },
                        )
                      : Text('Username: $_username'),

                  // Phone Number Field
                  _isEditing
                      ? TextFormField(
                          initialValue: _phoneNumber,
                          decoration:
                              const InputDecoration(labelText: 'Phone Number'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _phoneNumber = value!;
                          },
                        )
                      : Text('Phone Number: $_phoneNumber'),

                  // Bio Field
                  _isEditing
                      ? TextFormField(
                          initialValue: _bio,
                          decoration: const InputDecoration(labelText: 'Bio'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your bio';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _bio = value!;
                          },
                        )
                      : Text('Bio: $_bio'),

                  const SizedBox(height: 20),
                  // Save Button (Only visible in edit mode)
                  if (_isEditing)
                    ElevatedButton(
                      onPressed: _saveUserInfo,
                      child: const Text('Save'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Set the background color to red
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
