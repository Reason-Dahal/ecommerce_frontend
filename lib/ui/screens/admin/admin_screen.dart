import 'package:ecommerce_frontend/services/auth_service.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<AdminScreen> {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            await _authService.logout();

            if (!mounted) return;
            navigator.pushReplacementNamed('/auth');
          },
          child: Text("admin logout"),
        ),
      ),
    );
  }
}
