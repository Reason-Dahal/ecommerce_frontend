import 'package:ecommerce_frontend/routes/route.dart';
import 'package:ecommerce_frontend/ui/screens/auth/auth_screen.dart';
import 'package:ecommerce_frontend/ui/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SastoTrade',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.generate,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<bool> _hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _hasToken(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User logged in
        if (snapshot.data == true) {
          return const HomeScreen();
        }

        // User not logged in
        return const AuthScreen();
      },
    );
  }
}
