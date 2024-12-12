import 'package:do_an_lien_nganh/user/models/user_model/user_model.dart';
import 'package:do_an_lien_nganh/user/screens/cart_screen/cart_screen.dart';
import 'package:do_an_lien_nganh/user/screens/custom_bottom_bar/custom_bottom_bar.dart';
import 'package:do_an_lien_nganh/user/widgets/primary_button/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../firebase_helper/firebase_firestorage_helper/firebase_firestore.dart';
import '../../models/routes/routes.dart';
import '../../provider/app_provider.dart';
import '../../stripe_helper/stripe_cart_helper.dart';
import '../../stripe_helper/stripe_helper.dart';
import '../cart_screen/widgets/single_cart_item.dart';
import '../home/home.dart';

class CheckOutfromCart extends StatefulWidget {
  const CheckOutfromCart({super.key});

  @override
  State<CheckOutfromCart> createState() => _CheckOutfromCartState();
}

class _CheckOutfromCartState extends State<CheckOutfromCart> {
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController address = TextEditingController();
  int groupValue = 1;
  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context);
    UserModel user = appProvider.getUserInformation;

    String formatPrice(int price) {
      return price.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (Match m) => "${m[0]}.",
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          color: Colors.red,
          onPressed: () {
            Navigator.of(context).pop(); // Trở về màn hình trước
          },
        ),
        title: Text(
          "Check Out",
          style: TextStyle(
            color: Colors.red,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: appProvider.getCartProductList.length,
                  padding: EdgeInsets.all(15),
                  itemBuilder: (ctx, index) {
                    return SingleCartItem(
                      singleProduct: appProvider.getCartProductList[index],
                    );
                  }),
            ),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: name..text = user.name,
                        decoration: InputDecoration(
                          labelText: 'Name',
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: phone..text = user.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                        ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: address..text = user.address ?? '',
                  decoration: InputDecoration(
                    labelText: 'Address',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 40,
                      width: 180,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red, width: 2)),
                      child: Row(
                        children: [
                          Radio(
                              value: 1,
                              groupValue: groupValue,
                              onChanged: (value) {
                                setState(() {
                                  groupValue = value!;
                                });
                              }),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            'Cash',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 180,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red, width: 2)),
                      child: Row(
                        children: [
                          Radio(
                              value: 2,
                              groupValue: groupValue,
                              onChanged: (value) {
                                setState(() {
                                  groupValue = value!;
                                });
                              }),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            'Pay Online',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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
                title: 'Buy',
                onPressed: () async{
                  if (groupValue == 1) {
                    appProvider.getBuyProductList.clear();
                    appProvider.addBuyProductCartList();
                    bool value = await FirebaseFirestoreHelper.instance
                        .uploadOrderedProductFirebase(
                            appProvider.getBuyProductList,
                            context,
                            "Cash on Delivery",
                            name.text,
                            phone.text,
                            address.text);
                    if (value) {
                      Future.delayed(Duration(seconds: 2), () {
                        appProvider.clearCart();
                        Routes.instance
                            .pushAndRemoveUntil(widget: CartScreen(), context: context);
                      });
                    }
                  } else {
                    int value =
                    double.parse(appProvider.totalPrice().toString())
                        .round()
                        .toInt();
                    String totalPrice = (value).toString();
                    await StripeCartHelper.instance.makePayment(totalPrice, context,
                        appProvider.getCartProductList);
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
