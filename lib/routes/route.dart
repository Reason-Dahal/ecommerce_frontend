import 'package:ecommerce_frontend/ui/screens/admin/admin_screen.dart';
import 'package:ecommerce_frontend/ui/screens/auth/auth_screen.dart';
import 'package:ecommerce_frontend/ui/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/admin':
        return MaterialPageRoute(builder: (_) => const AdminScreen());

      case '/auth':
        return MaterialPageRoute(builder: (_) => const AuthScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text("Page not found"))),
        );
    }
  }
}
