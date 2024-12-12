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

class EditCategory extends StatefulWidget {
  const EditCategory(
      {super.key, required this.categoryModel, required this.index});
  final CategoryModel categoryModel;
  final index;

  @override
  State<EditCategory> createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
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
          'Edit Category',
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
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white, // White background
                shape: BoxShape.rectangle, // Square shape
                borderRadius: BorderRadius.circular(8), // Optional rounded corners
                image: DecorationImage(
                  image: NetworkImage(widget.categoryModel.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
              : CupertinoButton(
            onPressed: () {
              takePicture();
            },
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white, // White background
                shape: BoxShape.rectangle, // Square shape
                borderRadius: BorderRadius.circular(8), // Optional rounded corners
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
            controller: name..text = widget.categoryModel.name,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 24.0,
          ),
          PrimaryButton(
            title: "Update",
            onPressed: () async {
              if (image == null && name.text.isEmpty) {
                Navigator.of(context).pop();
                showMessage('All Field are empty');
              } else if (image != null) {
                String imageUrl = await FirebaseStorageHelper.instance
                    .uploadCategoryImage(widget.categoryModel.id, image!);
                CategoryModel categoryModel = widget.categoryModel
                    .copyWith(image: imageUrl, name: name.text);
                appProvider.updateCategoryList(widget.index, categoryModel);
                showMessage('Update Complete');
                Navigator.of(context, rootNavigator: true).pop();
              } else {
                CategoryModel categoryModel =
                    widget.categoryModel.copyWith(name: name.text);
                appProvider.updateCategoryList(widget.index, categoryModel);
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
