import 'dart:convert';
import 'package:do_an_lien_nganh/user/screens/cart_screen/cart_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../firebase_helper/firebase_firestorage_helper/firebase_firestore.dart';
import '../models/routes/routes.dart';
import '../provider/app_provider.dart';

class StripeCartHelper {
  static StripeCartHelper instance = StripeCartHelper();

  Map<String, dynamic>? paymentIntent;
  Future<void> makePayment(
      String amount, BuildContext context, List item) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'VND');

      var gpay = const PaymentSheetGooglePay(
          merchantCountryCode: "VN", currencyCode: "VND", testEnv: true);

      //STEP 2: Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent![
              'client_secret'], //Gotten from payment intent
              style: ThemeMode.light,
              merchantDisplayName: 'BLTech',
              googlePay: gpay))
          .then((value) {});

      //STEP 3: Display Payment sheet
      displayPaymentSheet(context, item);
    } catch (err) {
      showMessage(err.toString());
    }
  }

  displayPaymentSheet(BuildContext context, List item) async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        appProvider.addBuyProductCartList();
        bool value =
        await FirebaseFirestoreHelper.instance.uploadOrderedProductFirebase(
          appProvider.getBuyProductList,
          context,
          "Pay Online",
          appProvider.getUserInformation.name,
          appProvider.getUserInformation.phone,
          appProvider.getUserInformation.address,
        );
        if (value) {
          Future.delayed(Duration(seconds: 2), () {
            item.clear();
            Routes.instance
                .pushAndRemoveUntil(widget: CartScreen(), context: context);
          });
        }
      });
    } catch (e) {
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
          'Bearer sk_test_51QA911IhNCQmjd7dD3QUGmZLH9uqNeKtGdsKPzmEzqcyHjCVLmddsRLorvps2WfmIIUhHU2dw6gEH31njSHTGUyx00hSKNv1z1',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
    }
  }
}
