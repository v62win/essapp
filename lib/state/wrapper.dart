import 'package:flutter/material.dart';
import 'shared_preference_services.dart';
import 'package:ess_app/views/auth.dart';
import 'package:ess_app/views/dashboard.dart';


class Authwrapper extends StatefulWidget {
  const Authwrapper({super.key});

  @override
  State<Authwrapper> createState() => _AuthwrapperState();
}

class _AuthwrapperState extends State<Authwrapper> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SharedPreferencesService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the login status
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          // If there's an error retrieving login status
          return const Scaffold(
            body: Center(child: Text('Something went wrong!')),
          );
        }
        if (snapshot.hasData && snapshot.data == true) {
          // If user is logged in, show Dashboard
          return const Dash();
        } else {
          // If user is not logged in, show Auth screen
          return const Auth();
        }
      },
    );
  }
}
