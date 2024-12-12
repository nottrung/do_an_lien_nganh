import 'dart:io';
import 'package:do_an_lien_nganh/admin/models/category_model/category_model.dart';
import 'package:do_an_lien_nganh/admin/models/product_model/product_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../user/constants/constants.dart';
import '../../../../user/widgets/primary_button/primary_button.dart';
import '../../../helpers/firebase_storage_helper/firebase_storage_helper.dart';
import '../../../provider/app_provider.dart';

class AddProducts extends StatefulWidget {
  const AddProducts({super.key});

  @override
  State<AddProducts> createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  File? image;

  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController qty = TextEditingController();

  CategoryModel? _selectedCategory;

  void takePicture() async {
    XFile? value = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 40);
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
          'Add Products',
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
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                CupertinoIcons.capslock_fill,
                size: 40,
                color: Colors.black,
              ),
              alignment: Alignment.center,
            ),
          )
              : CupertinoButton(
            onPressed: takePicture,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(image!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          DropdownButtonFormField<CategoryModel>(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            value: _selectedCategory,
            hint: Text('Select A Category'),
            isExpanded: true,
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            items: appProvider.getCategoriesList.map((CategoryModel val) {
              return DropdownMenuItem<CategoryModel>(
                value: val,
                child: Text(val.name),
              );
            }).toList(),
          ),
          const SizedBox(height: 24.0),
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
            controller: qty,
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
            title: "Add Product",
            onPressed: () async {
              if (image == null ||
                  _selectedCategory == null ||
                  name.text.isEmpty ||
                  description.text.isEmpty ||
                  price.text.isEmpty ||
                  qty.text.isEmpty) {
                showMessage('Some Fields are empty');
              } else {
                appProvider.addProductList(
                    image!,
                    name.text,
                    _selectedCategory!.id,
                    removeDots(price.text), // Save raw price without dots
                    description.text,
                    int.parse(qty.text)
                );
                showMessage('Added Complete');
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}