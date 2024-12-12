import 'package:do_an_lien_nganh/user/constants/constants.dart';
import 'package:do_an_lien_nganh/user/firebase_helper/firebase_auth_helper/firebase_auth_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/user_model/user_model.dart';
import '../../widgets/primary_button/primary_button.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController newpassword = TextEditingController();
  TextEditingController repassword = TextEditingController();
  bool _isObscured = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          color: Colors.red,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Change Password",
          style: TextStyle(
            color: Colors.red,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          TextField(
            controller: newpassword,
            obscureText: _isObscured,
            decoration: InputDecoration(
              suffixIcon: CupertinoButton(
                child: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              ),
              border: OutlineInputBorder(),
              label: Text(
                'New Password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xffff4242),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          TextField(
            controller: repassword,
            obscureText: _isObscured,
            decoration: InputDecoration(
              suffixIcon: CupertinoButton(
                child: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              ),
              border: OutlineInputBorder(),
              label: Text(
                'Rewrite Password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xffff4242),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 24.0,
          ),
          PrimaryButton(
            title: "Update",
            onPressed: () async {
              if (newpassword.text.isEmpty) {
                showMessage("New Password is empty");
              } else if (repassword.text.isEmpty) {
                showMessage("Confirm Password is empty");
              } else if (repassword.text == newpassword.text) {
                FirebaseAuthHelper.intance
                    .changePassword(newpassword.text, context);
              } else {
                showMessage("Confrim Password is not match");
              }
            },
          ),
        ],
      ),
    );
  }
}
