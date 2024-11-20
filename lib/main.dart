import 'package:flutter/material.dart';
import 'package:ess_app/views/splashscreen.dart';
import 'package:flutter/services.dart';
import 'perm/service_locator.dart';
import 'views/dashboard.dart';
import 'views/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Use 'home' for the initial screen
      home: const Splash(),
      // Define routes for other screens
      routes: {
        '/dash': (context) => Dash(),
        '/profile': (context) => ProfileScreen(),
        '/attendance': (context) => AttendanceScreen(),
        '/auth': (context) => Auth(),
      },
    );
  }
}


