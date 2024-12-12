import 'dart:io';
import 'package:do_an_lien_nganh/admin/models/product_model/product_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../user/constants/constants.dart';
import '../../../../user/widgets/primary_button/primary_button.dart';
import '../../../helpers/firebase_storage_helper/firebase_storage_helper.dart';
import '../../../provider/app_provider.dart';

class EditProducts extends StatefulWidget {
  const EditProducts(
      {super.key, required this.index, required this.productModel});
  final ProductModel productModel;
  final index;

  @override
  State<EditProducts> createState() => _EditProductsState();
}

class _EditProductsState extends State<EditProducts> {
  File? image;
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController qty = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with product data
    name.text = widget.productModel.name;
    description.text = widget.productModel.description;
    price.text = formatPrice(widget.productModel.price);
    qty.text = widget.productModel.qty.toString();
  }

  void takePicture() async {
    XFile? value = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 40);
    if (value != null) {
      setState(() {
        image = File(value.path);
      });
    }
  }

  // Format price with dots as thousands separators
  String formatPrice(String price) {
    return price.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => "${m[0]}.",
    );
  }

  // Remove dots for saving to the database
  String removeDots(String price) {
    return price.replaceAll('.', '');
  }

  // Handle price input formatting
  void formatPriceInput(String input) {
    String newText = removeDots(input);
    if (newText.isNotEmpty) {
      // Convert to number then format back to string with dots
      int value = int.tryParse(newText) ?? 0;
      price.text = formatPrice(value.toString());
      // Move cursor to the end of the input
      price.selection = TextSelection.fromPosition(TextPosition(offset: price.text.length));
    }
  }

  @override
  Widget build(BuildContext context) {
    AdminAppProvider appProvider = Provider.of<AdminAppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Products',
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
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: [
          image == null
              ? CupertinoButton(
            onPressed: takePicture,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(widget.productModel.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
              : CupertinoButton(
            onPressed: takePicture,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(image!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: name,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24.0),
          TextFormField(
            keyboardType: TextInputType.number,
            controller: price,
            decoration: InputDecoration(
              labelText: 'Price',
              border: OutlineInputBorder(),
            ),
            onChanged: formatPriceInput, // Format input on change
          ),
          const SizedBox(height: 24.0),
          TextFormField(
            keyboardType: TextInputType.number,
            controller: qty..text = widget.productModel.qty.toString(),
            decoration: InputDecoration(
              labelText: 'Qty',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24.0),
          TextFormField(
            maxLines: 6,
            controller: description,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24.0),
          PrimaryButton(
            title: "Update",
            onPressed: () async {
              if (image == null &&
                  name.text.isEmpty &&
                  description.text.isEmpty &&
                  price.text.isEmpty &&
                  qty.text.isEmpty) {
                Navigator.of(context).pop();
                showMessage('All fields are empty');
              } else {
                ProductModel productModel = widget.productModel.copyWith(
                  description: description.text.isEmpty ? null : description.text,
                  image: image != null ? await FirebaseStorageHelper.instance.uploadProductImage(widget.productModel.id, image!) : widget.productModel.image,
                  name: name.text.isEmpty ? null : name.text,
                  price: removeDots(price.text), // Save raw price without dots
                  qty: qty.text.isEmpty ? null : int.tryParse(qty.text),
                );
                appProvider.updateProductList(widget.index, productModel);
                showMessage('Update Complete');
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}