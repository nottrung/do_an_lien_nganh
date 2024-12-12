import 'package:do_an_lien_nganh/admin/models/category_model/category_model.dart';
import 'package:do_an_lien_nganh/admin/screens/categories_view/edit_category/edit_category.dart';
import 'package:do_an_lien_nganh/user/models/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/app_provider.dart';

class SingleCategoryCard extends StatefulWidget {
  const SingleCategoryCard(
      {super.key, required this.singleCategory, required this.index});
  final CategoryModel singleCategory;
  final int index;

  @override
  State<SingleCategoryCard> createState() => _SingleCategoryCardState();
}

class _SingleCategoryCardState extends State<SingleCategoryCard> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    AdminAppProvider appProvider = Provider.of<AdminAppProvider>(context);

    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: widget.singleCategory.image == ''
                  ? Center(child: CircularProgressIndicator())
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(widget.singleCategory.image)),
            ),
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
                        widget: EditCategory(
                          categoryModel: widget.singleCategory,
                          index: widget.index,
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
                      await appProvider
                          .deleteCategoryFromFirebase(widget.singleCategory);
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
    );
  }
}
