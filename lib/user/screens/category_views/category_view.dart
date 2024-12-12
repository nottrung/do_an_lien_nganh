import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../firebase_helper/firebase_firestorage_helper/firebase_firestore.dart';
import '../../models/category_model/category_model.dart';
import '../../models/product_model/product_model.dart';
import '../../models/routes/routes.dart';
import '../../provider/app_provider.dart';
import '../product_details/product_details.dart';

class CategoryView extends StatefulWidget {
  final CategoryModel categoryModel;
  const CategoryView({super.key, required this.categoryModel});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  bool isLoading = false;
  List<ProductModel> productModelList = [];

  void getCategoryList() async {
    setState(() {
      isLoading = true;
    });
    productModelList = await FirebaseFirestoreHelper.instance
        .getCategoryViewProduct(widget.categoryModel.id);
    productModelList.shuffle();

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getCategoryList();
    super.initState();
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

    return Scaffold(
      body: isLoading
          ? Center(
              child: Container(
                height: 100,
                width: 100,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new),
                          color: Colors.red,
                          onPressed: () {
                            Navigator.of(context)
                                .pop(); // Trở về màn hình trước
                          },
                        ),
                        Text(
                          widget.categoryModel.name,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffff4242),
                          ),
                        ),
                      ],
                    ),
                  ),
                  productModelList.isEmpty
                      ? Center(child: Text('Products are empty'))
                      : Padding(
                          padding: const EdgeInsets.only(left: 12.0, right: 12),
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            primary: false,
                            itemCount: productModelList.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20,
                              childAspectRatio: 0.8,
                            ),
                            itemBuilder: (ctx, index) {
                              ProductModel singleProduct =
                                  productModelList[index];
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xffff4242),
                                      Color(0xffefd7dc)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      children: [
                                        singleProduct.image == ''
                                            ? CircularProgressIndicator() // Hiển thị indicator nếu chưa có URL
                                            : Image.network(
                                                singleProduct.image,
                                                height: 100,
                                                width: 100,
                                              ),
                                        SizedBox(height: 12),
                                        Text(
                                          singleProduct.name,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                            'Price: ${formatPrice(singleProduct.price)} VND'),
                                        SizedBox(height: 12),
                                        SizedBox(
                                          height: 45,
                                          width: 140,
                                          child: OutlinedButton(
                                            onPressed: () {
                                              Routes.instance.push(
                                                  widget: ProductDetails(
                                                    singleProduct:
                                                        singleProduct, userModel: appProvider.getUserInformation,
                                                  ),
                                                  context: context);
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              surfaceTintColor: Colors.white,
                                              shadowColor: Colors.white,
                                              side: BorderSide(
                                                  color: Colors.white,
                                                  width: 2),
                                              disabledForegroundColor: Colors
                                                  .white
                                                  .withOpacity(0.38),
                                            ),
                                            child: Text(
                                              'Buy',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  SizedBox(height: 15),
                ],
              ),
            ),
    );
  }
}
