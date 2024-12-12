import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../constants/constants.dart';
import '../../../models/user_model/user_model.dart';
import '../login/login.dart';


class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController rePassword = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();

  String? emailError;
  String? passwordError;

  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'Create Your\nAccount',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
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
                          controller: name,
                          decoration: InputDecoration(
                            suffixIcon: Icon(
                              Icons.face_retouching_natural,
                              color: Colors.grey,
                            ),
                            label: Text(
                              'Full Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xffff4242),
                              ),
                            ),
                          ),
                        ),
                        TextField(
                          controller: phone,
                          decoration: InputDecoration(
                            suffixIcon: Icon(
                              Icons.phone_android_sharp,
                              color: Colors.grey,
                            ),
                            label: Text(
                              'Phone number',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xffff4242),
                              ),
                            ),
                          ),
                        ),
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
                          ),
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
                          ),
                        ),
                        TextField(
                          controller: rePassword,
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
                              'Rewrite the password',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xffff4242),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                        GestureDetector(
                          onTap: () async {
                            if (password.text == rePassword.text) {
                              try {
                                // Register the user with Firebase Auth
                                showLoaderDialog(context);
                                UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                  email: email.text.trim(),
                                  password: password.text.trim(),
                                );

                                // Create a UserModel instance
                                UserModel userModel = UserModel(
                                  id: userCredential.user!.uid,
                                  name: name.text.trim(),
                                  email: email.text.trim(),
                                  phone: phone.text.trim(),
                                  image: null, // Add logic for default image if needed
                                  address: '', // Add default address if necessary
                                );

                                // Store user information in Firestore
                                await FirebaseFirestore.instance.collection('users').doc(userModel.id).set(userModel.toJson());

                                // Navigate to another screen after successful sign up
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => Login()), // Replace with your desired screen
                                      (Route<dynamic> route) => false,
                                );
                              } catch (e) {
                                // Handle registration error
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            } else {
                              // Handle password mismatch error
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Passwords do not match.")),
                              );
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
                                'CREATE ACCOUNT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 70),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Already have an account?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => Login()),
                                        (Route<dynamic> route) => false,
                                  );
                                },
                                child: Text(
                                  'Sign in',
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
          ),
        ],
      ),
    );
  }
}
