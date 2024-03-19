import 'package:camera_app/providers/camera_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  @override
  void dispose() {
    super.dispose();
  }
@override
Widget build(BuildContext context) {
  final cameraProvider = Provider.of<CameraProvider>(context);

  return Scaffold(
    body: Stack(
      children: [
        // Full-screen background image
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Image.asset(
            "images/goku.gif",
            fit: BoxFit.fill, // This ensures the image covers the whole screen
            
          ),
        ),
      
        Positioned(
          bottom: 20, // Adjust the positioning 
          left: 0,
          right: 0,
          child: Center( // Center the button horizontally
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await cameraProvider.login("user", "pass");
                  await Navigator.pushReplacementNamed(context, '/home');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed: $e'))
                  );
                }
              },
              child: const Text(
                "Login",
                textScaler: TextScaler.linear(3), // Adjust text scale factor 
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}
