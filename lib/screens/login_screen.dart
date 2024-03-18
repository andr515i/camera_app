import 'package:camera_app/providers/camera_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraProvider = Provider.of<CameraProvider>(context);
    return Scaffold(
      body: Center(
        child: Form(
            child: Column(
          children: [
            Container(
              height: 150,
            ),
            const Text("enter username:"),
            TextField(
              controller: _usernameController,
            ),
            const Text("enter password:"),
            TextField(
              controller: _passwordController,
              obscureText: true,
            ),
            ElevatedButton(
                onPressed: () async {
                  debugPrint(
                      'credentials captured: ${_usernameController.text} - ${_passwordController.text}');
                  try {
                    await cameraProvider.login(
                        _usernameController.text, _passwordController.text);
                    await Navigator.pushReplacementNamed(context, '/home');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Login failed: $e')));
                  }
                },
                child: const Text("login.")),
          ],
        )),
      ),
    );
  }
}
