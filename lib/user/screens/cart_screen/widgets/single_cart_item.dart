import 'package:do_an_lien_nganh/user/models/product_model/product_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/constants.dart';
import '../../../provider/app_provider.dart';

class SingleCartItem extends StatefulWidget {
  final ProductModel singleProduct;
  const SingleCartItem({super.key, required this.singleProduct});

  @override
  State<SingleCartItem> createState() => _SingleCartItemState();
}

class _SingleCartItemState extends State<SingleCartItem> {
  int qty = 1;

  bool isLoading = false;
  void initState() {
    super.initState();
    qty = widget.singleProduct.qty ?? 1;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context);

    String formatPrice(String price) {
      int priceInt = int.tryParse(price) ?? 0;
      return priceInt.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (Match m) => "${m[0]}.",
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red, width: 3),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 170,
              color: Colors.red.withOpacity(0.5),
              child: Image.network(
                widget.singleProduct.image,
                    ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: 170,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.singleProduct.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                AppProvider appProvider =
                                Provider.of<AppProvider>(context,
                                    listen: false);
                                appProvider
                                    .removeCartProduct(widget.singleProduct);
                                showMessage('Removed from Cart');
                              },
                              child: Icon(
                                Icons.delete,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            CupertinoButton(
                              onPressed: () {
                                if (qty > 1) {
                                  setState(() {
                                    qty--;
                                  });
                                  appProvider.updateQty(widget.singleProduct, qty);
                                }
                              },
                              padding: EdgeInsets.zero,
                              child: CircleAvatar(
                                maxRadius: 13,
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              qty.toString(),
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 5),
                            CupertinoButton(
                              onPressed: () {
                                setState(() {
                                  qty++;
                                });
                                appProvider.updateQty(widget.singleProduct, qty);
                              },
                              padding: EdgeInsets.zero,
                              child: CircleAvatar(
                                maxRadius: 13,
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 50,
                            ),
                            Text(
                              '${formatPrice(widget.singleProduct.price)} VND',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    ;
  }
}
