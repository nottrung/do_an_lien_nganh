import 'package:do_an_lien_nganh/user/firebase_helper/firebase_auth_helper/firebase_auth_helper.dart';
import 'package:do_an_lien_nganh/user/provider/app_provider.dart';
import 'package:do_an_lien_nganh/user/screens/auth_ui/welcome/welcome.dart';
import 'package:do_an_lien_nganh/user/screens/custom_bottom_bar/custom_bottom_bar.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'admin/provider/app_provider.dart'
    as admin_provider;
import 'admin/screens/home_page/home_page.dart';

void main() async {
  Stripe.publishableKey =
      "pk_test_51QA911IhNCQmjd7d1VkJsaSSsNLnOqT2d2sTb1GWjhxGC8GB3jUtLXmf0lXAdB08YoDQdbouj1OVgcruAQsMNdiE00F6DQ62Lg";

  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await initializeFirebase();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  // Start the app
  runApp(MyApp());
}

// Function to initialize Firebase
Future<void> initializeFirebase() async {
  if (kIsWeb) {
    // Web configuration for Firebase
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBz42kS_8mZ9byWpCjfpMYjzNF22lWGeKA",
          authDomain: "tech-shop-92030.firebaseapp.com",
          projectId: "tech-shop-92030",
          storageBucket: "tech-shop-92030.appspot.com",
          messagingSenderId: "1066657245388",
          appId: "1:1066657245388:web:0304a340542ef595ebfa69",
          measurementId: "G-66DL98NZFK"),
    );
  } else {
    // Mobile configuration for Firebase
    await Firebase.initializeApp();
  }
}

// Main application widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(
            create: (_) => admin_provider.AdminAppProvider()),
      ],
      child: MaterialApp(
        title: 'BLTech',
        theme: ThemeData(),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/admin':
              return MaterialPageRoute(
                builder: (context) => HomePage(), // Admin's HomePage
              );
            case '/user':
            default:
              return MaterialPageRoute(
                builder: (context) => WelcomeScreen(),
              );
          }
        },
        home: StreamBuilder<User?>(
          stream: FirebaseAuthHelper.intance.getAuthChange,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              final User? user = snapshot.data;
              if (user == null) {
                return WelcomeScreen();
              }
              return CustomBottomBar(); // Ensure CustomBottomBar can access AppProvider
            }
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
