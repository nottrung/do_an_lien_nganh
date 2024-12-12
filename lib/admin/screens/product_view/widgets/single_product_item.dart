import 'package:do_an_lien_nganh/user/models/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../admin/models/product_model/product_model.dart';
import '../../../provider/app_provider.dart';
import '../edit_products/edit_products.dart';

class SingleProductItem extends StatefulWidget {
  const SingleProductItem({
    super.key,
    required this.singleProduct,
    required this.index,
  });

  final int index;
  final ProductModel singleProduct;

  @override
  State<SingleProductItem> createState() => _SingleProductItemState();
}

class _SingleProductItemState extends State<SingleProductItem> {
  bool isLoading = false;

  String formatPrice(String price) {
    int priceInt = int.tryParse(price) ?? 0;
    return priceInt.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => "${m[0]}.",
    );
  }

  @override
  Widget build(BuildContext context) {
    AdminAppProvider appProvider = Provider.of<AdminAppProvider>(context);

    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    widget.singleProduct.image == ''
                        ? CircularProgressIndicator()
                        : Image.network(
                      widget.singleProduct.image,
                      height: 100,
                      width: 100,
                    ),
                    SizedBox(height: 12),
                    Text(
                      widget.singleProduct.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Price: ${formatPrice(widget.singleProduct.price)} VND'),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  left: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Routes.instance.push(
                              widget: EditProducts(
                                index: widget.index,
                                productModel: widget.singleProduct,
                              ),
                              context: context);
                        },
                        child: Icon(
                          Icons.edit,
                        ),
                      ),
                      IgnorePointer(
                        ignoring: isLoading,
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              isLoading = true;
                            });
                            await appProvider.deleteProductFromFirebase(
                                widget.singleProduct);
                            setState(() {
                              isLoading = false;
                            });
                          },
                          child: isLoading
                              ? CircularProgressIndicator()
                              : Icon(Icons.delete, color: Colors.red),
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
    );
  }
}