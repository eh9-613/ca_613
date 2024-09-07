import 'package:create_resolution_system_613/screens/admin_home.dart';
import 'package:create_resolution_system_613/screens/cmember_home.dart';
import 'package:create_resolution_system_613/screens/sadmin_home.dart';
import 'package:create_resolution_system_613/screens/login.dart';
import 'package:create_resolution_system_613/screens/submit_form.dart';
import 'package:create_resolution_system_613/screens/view_resolutions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      initialRoute: '/login',
      routes: {
        '/sAdminHome': (context) => const HomeScreen(),
        '/adminHome': (context) => const AdminHome(),
        '/memberHome': (context) => const MemberHome(),
        '/submitForm': (context) => const SubmitFormPage(),
        '/viewResolutions': (context) => const ViewResolutionsPage(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}