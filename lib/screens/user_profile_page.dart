import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final DBHelper _dbHelper = DBHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
  final user = await _dbHelper.getUserProfile();

  if (user != null) {
    _usernameController.text = user['username'];
    _ageController.text = user['age']?.toString() ?? '';
  } else {
    final username = await _dbHelper.getOrCreateUsername();
    _usernameController.text = username;
    _ageController.text = '';
  }
}


  Future<void> _save() async {
    final age = int.tryParse(_ageController.text);
    if (age == null) return;

    await _dbHelper.saveUserProfile(
      _usernameController.text,
      age,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}