import 'package:ecommerce_frontend/routes/route.dart';
import 'package:ecommerce_frontend/ui/screens/admin/admin_product_list_screen.dart';
import 'package:ecommerce_frontend/ui/screens/auth/auth_screen.dart';
import 'package:ecommerce_frontend/ui/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

/// Decides the start screen on app launch based on the stored token's
/// role, instead of always sending logged-in users to HomeScreen.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<String?> _getRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) return null;
    if (JwtDecoder.isExpired(token)) return null;

    final decoded = JwtDecoder.decode(token);
    return decoded['role'] ?? 'user';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data;

        if (role == null) return const AuthScreen();
        if (role == 'admin') return const AdminProductListScreen();

        return const HomeScreen();
      },
    );
  }
}
