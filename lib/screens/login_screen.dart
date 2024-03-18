import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Form(
            child: Column(
          children: [
            Text("enter username:"),
            TextField(),
            Text("enter password:"),
            TextField(),
            
          ],
        )),
      ),
    );
  }
}
