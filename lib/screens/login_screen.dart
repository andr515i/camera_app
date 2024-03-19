import 'package:camera_app/providers/camera_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
      body: Column(
        children: [
          // Full-screen background image
          const Expanded(
            child: Image(
              image: AssetImage("images/goku.gif"),
              fit: BoxFit.fill,
            ),

          ),
          Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await cameraProvider.login("user", "pass");
                        await Navigator.pushReplacementNamed(context, '/home');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Login failed: $e')));
                      }
                    },
                    child: const Text(
                      "Login",
                      textScaler:
                          TextScaler.linear(3), // Adjust text scale factor
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        cameraProvider.startIsolate();
                      },
                      child: const Icon(Icons.dangerous)),
                ],
              )
            )
        ],
      ),
    );
  }
}
