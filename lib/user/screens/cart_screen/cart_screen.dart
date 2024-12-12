import 'package:do_an_lien_nganh/user/models/routes/routes.dart';
import 'package:do_an_lien_nganh/user/screens/buy_product/buy_product.dart';
import 'package:do_an_lien_nganh/user/screens/cart_screen/widgets/single_cart_item.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/app_provider.dart';
import '../../widgets/primary_button/primary_button.dart';
import '../buy_product/buyProductfromCart.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isLoading = false;
  List<String> productImageUrls =
      []; // <-- Thêm danh sách lưu URL hình ảnh sản phẩm

  Future<String> getImageUrl(String imagePath) async {
    try {
      String downloadUrl =
          await FirebaseStorage.instance.ref(imagePath).getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error getting image URL: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context);

    String formatPrice(int price) {
      return price.toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (Match m) => "${m[0]}.",
          );
    }

    void showMessage(String message) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Notice'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: Text(
          'My Cart',
          style: TextStyle(color: Colors.red, fontSize: 30),
        ),
      ),
      body: appProvider.getCartProductList.isEmpty
          ? Center(
              child: Image.asset('assets/images/Empty_cart.jpg'),
            )
          : ListView.builder(
              itemCount: appProvider.getCartProductList.length,
              padding: EdgeInsets.all(15),
              itemBuilder: (ctx, index) {
                return SingleCartItem(
                  singleProduct: appProvider.getCartProductList[index],
                );
              }),
      bottomNavigationBar: SizedBox(
        height: 150,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${formatPrice(appProvider.totalPrice().toInt())} VND',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              PrimaryButton(
                title: 'Check Out',
                onPressed: () {
                  if (appProvider.totalPrice() == 0) {
                    showMessage('Your cart is empty!');
                  } else {
                    Routes.instance.push(widget: CheckOutfromCart(), context: context);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
