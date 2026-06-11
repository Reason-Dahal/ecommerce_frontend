import 'package:ecommerce_frontend/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void authButtonPressed() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (isLogin) {
          await _authService.login(
            emailController.text,
            passwordController.text,
          );
        } else {
          await _authService.signup(
            usernameController.text,
            emailController.text,
            passwordController.text,
          );
        }

        if (!mounted) return;

        //Decode token and redirect based on role
        final String? token = await _authService.getToken(); // get stored token

        if (token == null) {
          throw Exception('Token not found after authentication');
        }

        final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

        final String role =
            decodedToken['role'] ??
            'user'; // adjust key to match your JWT payload

        if (!mounted) return;

        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isLogin
                  ? 'Logged in successfully!'
                  : 'Account created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        usernameController.clear();
        emailController.clear();
        passwordController.clear();
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    isLogin
                        ? Text("LogIn", style: TextStyle(fontSize: 30))
                        : Text("SignUp", style: TextStyle(fontSize: 30)),

                    !isLogin
                        ? TextFormField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              hint: Text("username"),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "user name can't be empty";
                              }
                              if (value.length < 3) {
                                return "username must be atleast 3 character";
                              }
                              return null;
                            },
                          )
                        : SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hint: Text("email"),
                        prefixIcon: Icon(Icons.mail),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "email name can't be empty";
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "password can't be empty";
                        }
                        if (value.length < 8) {
                          return "passord must be atleast 8 character";
                        }
                        return null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        hint: Text("password"),
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: authButtonPressed,
                      child: Text(isLogin ? "LogIn" : "signUp"),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                        });
                      },
                      child: isLogin
                          ? Text("doesn't have an account? signUp")
                          : Text("already have an account? Login"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
