import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../firebase_helper/firebase_auth_helper/firebase_auth_helper.dart';
import '../login/login.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _email = TextEditingController();
  final _auth = FirebaseAuthHelper();

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handlePasswordReset() async {
    // Check if the email exists in the database
    bool emailExists = await _auth.checkEmailExists(_email.text.trim());

    if (!emailExists) {
      // If email does not exist, show an error message
      showMessage('Email is not exist');
    } else {
      // If email exists, send the password reset link
      await _auth.sendPasswordResetLink(_email.text.trim(), context);
        showMessage('Password reset link successfully sent');

      // Delay for 1 second and navigate to LoginScreen
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forget Password',
          style: TextStyle(
            color: Colors.red,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          color: Colors.red,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text('Enter email to send password reset link'),
            SizedBox(height: 15),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: _email,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text(
                  'Send Email',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xffff4242),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handlePasswordReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text(
                  'Send Email',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
