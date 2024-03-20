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
    final cameraProvider = Provider.of<CameraProvider>(context); // get provider with the same context as the main isolate's provider. this doesnt mean its the same provider, as it still gets initialized in here.

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
                        await cameraProvider.login("user", "pass");   //try and login. for now, there will be no custom credentials, however, future expansion could easily add some form with username and password, aswell as some controllers that check for x and y.

                        await Navigator.pushReplacementNamed(context, '/home');   //if successfull login (credentials are correct AND access to api or mock api (always accessible.))

                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Login failed: $e'))); // show the reason for login failure as a snackbar. could make this a notifcation just to show that we can make notifications based on button presses in the app.
                      }
                    },
                    child: const Text(
                      "Login",
                      textScaler:
                          TextScaler.linear(3), // Adjust text scale factor
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        await cameraProvider.startIsolate();  // call the isolate starter to test the very simple isolates.
                      },
                      child: const Icon(Icons.dangerous)),
                  ElevatedButton(
                      onPressed: () async {
                        await cameraProvider.sendNotification();  // call the isolate starter to test the very simple isolates.
                      },
                      child: const Icon(Icons.notification_add)),
                ],
              )
            )
        ],
      ),
    );
  }
}
