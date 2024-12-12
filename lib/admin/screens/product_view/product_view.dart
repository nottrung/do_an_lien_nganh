import 'package:do_an_lien_nganh/admin/models/product_model/product_model.dart';
import 'package:do_an_lien_nganh/admin/screens/product_view/widgets/single_product_item.dart';
import 'package:do_an_lien_nganh/user/models/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/app_provider.dart';
import 'add_products/add_products.dart';

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  @override
  Widget build(BuildContext context) {

    AdminAppProvider appProvider = Provider.of<AdminAppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Products View',
          style: TextStyle(
            color: Colors.red,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          color: Colors.red,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                Routes.instance.push(widget: AddProducts(), context: context);
              },
              icon: Icon(
                Icons.add_circle,
                size: 35,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            shrinkWrap: true,
            primary: false,
            itemCount: appProvider.getProductList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (ctx, index) {
              ProductModel singleProduct = appProvider.getProductList[index];
              return SingleProductItem(singleProduct: singleProduct, index: index,);
            },
          ),
        ),
      ),
    );
  }
}

