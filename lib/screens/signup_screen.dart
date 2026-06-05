import 'package:ecommerce_flutter/models/user_model.dart';
import 'package:ecommerce_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              // obscureText: true,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                UserModel? user = await _authService.signup(
                  usernameController.text.trim(),
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
                // ignore: unnecessary_null_comparison
                if (user != null && context.mounted) {
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(builder: (_) => const HomeScreen()),
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sign Up Success")),
                  );
                  // );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signup Failed')),
                  );
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
