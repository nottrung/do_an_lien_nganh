import 'package:do_an_lien_nganh/user/constants/constants.dart';
import 'package:do_an_lien_nganh/user/firebase_helper/firebase_auth_helper/firebase_auth_helper.dart';
import 'package:do_an_lien_nganh/user/models/routes/routes.dart';
import 'package:do_an_lien_nganh/user/screens/auth_ui/forget_password_screen/forget_password_screen.dart';
import 'package:flutter/material.dart';

import '../../custom_bottom_bar/custom_bottom_bar.dart';
import '../../home/home.dart';
import '../sign_up/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool _isObscured = true;

  String? emailError;
  String? passwordError;

  void clearErrors() {
    setState(() {
      emailError = null;
      passwordError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffff4242), Color(0xffefd7dc)],
                stops: [0.25, 1],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 60, left: 22),
              child: Text(
                'Welcome back\nSign in!',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.only(top: 250),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Icons.account_circle_sharp,
                            color: Colors.grey,
                          ),
                          label: Text(
                            'Email',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffff4242),
                            ),
                          ),
                          errorText: emailError,
                        ),
                        onChanged: (text) => clearErrors(),
                      ),
                      TextField(
                        controller: password,
                        obscureText: _isObscured,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                          ),
                          label: Text(
                            'Password',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffff4242),
                            ),
                          ),
                          errorText: passwordError,
                        ),
                        onChanged: (text) => clearErrors(),
                      ),
                      SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Routes.instance.push(widget: ForgetPasswordScreen(), context: context);
                          },
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffff4242),
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 70),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            emailError = email.text.isEmpty ? 'Email is required' : null;
                            passwordError = password.text.isEmpty ? 'Password is required' : null;
                          });

                          if (email.text.isNotEmpty && password.text.isNotEmpty) {
                            bool isVaildated =
                            loginValidation(email.text, password.text);
                            if (isVaildated) {
                              bool isLogined = await FirebaseAuthHelper.intance
                                  .login(email.text, password.text, context);
                              if (isLogined) {
                                String userName = await FirebaseAuthHelper.intance.getUserName(email.text);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => CustomBottomBar()),
                                      (Route<dynamic> route) => false,
                                );
                              }
                            }
                          }
                        },
                        child: Container(
                          height: 55,
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              colors: [Color(0xffefd7dc), Color(0xffff4242)],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'SIGN IN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 150),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Do not have account?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUp()),
                                      (Route<dynamic> route) => false,
                                );
                              },
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
