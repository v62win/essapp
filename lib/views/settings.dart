import 'package:ess_app/state/shared_preference_services.dart';
import 'package:ess_app/views/auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'faceregistration.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;


  Future<void> signOut() async {
    SharedPreferencesService().setLoggedIn(false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('Atoken');
    await prefs.remove('Rtoken');
    await prefs.remove('name');
    await prefs.remove('idemp');
    await prefs.remove('profileImagePath');
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Auth()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Dark Mode Toggle
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (bool value) {
              setState(() {
                isDarkMode = value;
              });
            },
            secondary: const Icon(Icons.dark_mode),
          ),
         /* const Divider(),

          // Notifications Toggle
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
            secondary: const Icon(Icons.notifications),
          ),*/
          const Divider(),

          // Logout button
          ListTile(
            title: const Text('Face Registration'),
            leading: const Icon(Icons.person),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FaceRegistrationScreen()));
            },
          ),
          const Divider(),

          // Logout button
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout),
            onTap: () {
              signOut();
            },
          ),
        ],
      ),
    );
  }
}
