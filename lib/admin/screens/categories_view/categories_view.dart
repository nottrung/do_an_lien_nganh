import 'package:do_an_lien_nganh/admin/models/category_model/category_model.dart';
import 'package:do_an_lien_nganh/admin/provider/app_provider.dart';
import 'package:do_an_lien_nganh/admin/screens/categories_view/add_category/add_category.dart';
import 'package:do_an_lien_nganh/admin/screens/categories_view/single_category_card/single_category_card.dart';
import 'package:do_an_lien_nganh/user/models/routes/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  bool isLoading = false;

  Future<void> _loadCategories() async {
    setState(() {
      isLoading = true;
    });
    await Provider.of<AdminAppProvider>(context, listen: false)
        .getCategoriesListFun();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Categories View',
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
                Routes.instance.push(widget: AddCategory(), context: context);
              },
              icon: Icon(
                Icons.add_circle,
                size: 35,
              ))
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadCategories,
              child:
                  Consumer<AdminAppProvider>(builder: (context, value, child) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    primary: false,
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(12),
                    itemCount: value.getCategoriesList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1, // Tỉ lệ kích thước của ô
                    ),
                    itemBuilder: (context, index) {
                      CategoryModel categoryModel =
                          value.getCategoriesList[index];
                      return SingleCategoryCard(
                        singleCategory: categoryModel,
                        index: index,
                      );
                    },
                  ),
                );
              }),
            ),
    );
  }
}
