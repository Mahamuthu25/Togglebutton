import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:togglebutton/firebaseLogin/count_screen.dart';
import 'package:togglebutton/firebaseLogin/registerpage.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
   final _formKey = GlobalKey<FormState>();

  Future<void> loginUser() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.push(context, MaterialPageRoute(builder: (_) => CountScreen()));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login Success")));


    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
  key: _formKey,
  child: Column(
    children: [

      TextFormField(
        controller: emailController,
        decoration: InputDecoration(
          labelText: "Email",
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Email is required";
          }

          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
              .hasMatch(value.trim())) {
            return "Enter valid email";
          }

          return null;
        },
      ),

      SizedBox(height: 20),

      TextFormField(
        controller: passwordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: "Password",
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Password is required";
          }

          if (value.length < 6) {
            return "Password must be at least 6 characters";
          }

          return null;
        },
      ),

            SizedBox(height: 30),

            ElevatedButton(onPressed: loginUser, child: Text("Login")),

            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterPage()),
                );
              },
              child: Text("Create new account"),
            ),
          ],
        ),
      ),
      )
    );
  }
}
