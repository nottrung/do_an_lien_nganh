import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

void showMessage(String message) {
  Fluttertoast.showToast(
    msg: message,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

showLoaderDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Builder(builder: (context) {
      return SizedBox(
        width: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xffe16555),
            ),
            const SizedBox(
              height: 18.0,
            ),
            Container(
                margin: const EdgeInsets.only(left: 7),
                child: const Text("Loading...")),
          ],
        ),
      );
    }),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

String getMessageFromErrorCode(String errorCode) {
  switch (errorCode) {
    case "ERROR_EMAIL_ALREADY_IN_USE":
      return "Email already used. Go to login page.";
    case "account-exists-with-different-credential":
      return "Email already used. Go to login page.";
    case "email-already-in-use":
      return "Email already used. Go to login page.";
    case "ERROR_WRONG_PASSWORD":
    case "wrong-password":
      return "Wrong Password ";
    case "ERROR_USER_NOT_FOUND":
      return "No user found with this email.";
    case "user-not-found":
      return "No user found with this email.";
    case "ERROR_USER_DISABLED":
      return "User disabled.";
    case "user-disabled":
      return "User disabled.";
    case "ERROR_TOO_MANY_REQUESTS":
      return "Too many requests to log into this account.";
    case "operation-not-allowed":
      return "Too many requests to log into this account.";
    case "ERROR_OPERATION_NOT_ALLOWED":
      return "Too many requests to log into this account.";
    case "ERROR_INVALID_EMAIL":
      return "Email address is invalid.";
    case "invalid-email":
      return "Email address is invalid.";
    default:
      return "Login failed. Please try again.";
  }
}

bool loginValidation(String email, String password) {
  if (email.isEmpty && password.isEmpty) {
    showMessage('Both fields are empty');
    return false;
  } else if (email.isEmpty) {
    showMessage('Email is empty');
    return false;
  } else if (password.isEmpty) {
    showMessage('Password is empty');
    return false;
  } else {
    return true;
  }
}

bool signUpValidation(String email, String password, String name, String phone, String rePassword) {
  if (email.isEmpty && password.isEmpty && name.isEmpty && phone.isEmpty && rePassword.isEmpty) {
    showMessage('All fields are empty');
    return false;
  } else if (email.isEmpty) {
    showMessage('Email is empty');
    return false;
  } else if (password.isEmpty) {
    showMessage('Password is empty');
    return false;
  } else if (name.isEmpty) {
    showMessage('Name is empty');
    return false;
  } else if (phone.isEmpty) {
    showMessage('Phone is empty');
    return false;
  } else if (rePassword.isEmpty) {
    showMessage('Rewrite Password is empty');
    return false;
  } else if (rePassword != password) {
    showMessage('Password and rewrite password do not match');
    return false;
  } else if (password.length < 8) {
    showMessage('Password must have at least 8 characters');
    return false;
  } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
    showMessage('Password must contain at least one uppercase letter');
    return false;
  } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
    showMessage('Password must contain at least one special character');
    return false;
  } else {
    return true;
  }
}
