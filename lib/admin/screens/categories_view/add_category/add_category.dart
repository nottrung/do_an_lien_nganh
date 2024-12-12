import 'dart:io';
import 'package:do_an_lien_nganh/admin/constants/constants.dart';
import 'package:do_an_lien_nganh/admin/helpers/firebase_storage_helper/firebase_storage_helper.dart';
import 'package:do_an_lien_nganh/admin/models/category_model/category_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../user/widgets/primary_button/primary_button.dart';
import '../../../provider/app_provider.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  File? image;
  void takePicture() async {
    XFile? value = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 40);
    if (value != null) {
      setState(() {
        image = File(value.path);
      });
    }
  }

  TextEditingController name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AdminAppProvider appProvider = Provider.of<AdminAppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Category',
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
                  onPressed: () {
                    takePicture();
                  },
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
                      size: 40, // Icon size
                      color: Colors.black,
                    ),
                    alignment: Alignment.center,
                  ),
                )
              : CupertinoButton(
                  onPressed: () {
                    takePicture();
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white, // White background
                      shape: BoxShape.rectangle, // Square shape
                      borderRadius:
                          BorderRadius.circular(8), // Optional rounded corners
                      image: DecorationImage(
                        image: FileImage(image!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
          SizedBox(
            height: 15,
          ),
          TextFormField(
            controller: name,
            decoration: InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 24.0,
          ),
          PrimaryButton(
            title: "Add Category",
            onPressed: () async {
              if (image == null && name.text.isEmpty) {
                Navigator.of(context).pop();
                showMessage('All Fields are empty');
              } else if (image != null && name.text.isNotEmpty) {
                Future.delayed(Duration(seconds: 1), () {
                  appProvider.addCategoryList(image!, name.text);
                  showMessage('Added Complete');
                  Navigator.of(context, rootNavigator: true).pop();
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
