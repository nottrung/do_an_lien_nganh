import 'package:do_an_lien_nganh/user/firebase_helper/firebase_firestorage_helper/firebase_firestore.dart';
import 'package:do_an_lien_nganh/user/models/category_model/category_model.dart';
import 'package:do_an_lien_nganh/user/models/product_model/product_model.dart';
import 'package:do_an_lien_nganh/user/provider/app_provider.dart';
import 'package:do_an_lien_nganh/user/screens/category_views/category_view.dart';
import 'package:do_an_lien_nganh/user/screens/product_details/product_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/routes/routes.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CategoryModel> categoriesList = [];
  List<ProductModel> productModelList = [];
  List<ProductModel> filteredProducts = [];
  bool isLoading = false;

  // Initialize a map to store the checkbox values
  Map<String, bool> priceFilters = {
    '< 1.000.000 VND': false,
    '1.000.000 VND - 5.000.000 VND': false,
    '5.000.000 VND - 15.000.000 VND': false,
    '15.000.000 VND - 30.000.000 VND': false,
    '30.000.000 VND - 50.000.000 VND': false,
    '> 50.000.000 VND': false,
  };

  @override
  void initState() {
    super.initState();
    getCategoryList();
    AppProvider appProvider = Provider.of(context, listen: false);
    appProvider.getUserInfoFireBase();
  }

  Future<void> getCategoryList() async {
    setState(() {
      isLoading = true;
    });

    FirebaseFirestoreHelper.instance.updateTokenFromFirebase();
    categoriesList = await FirebaseFirestoreHelper.instance.getCategories();
    productModelList = await FirebaseFirestoreHelper.instance.getBestProducts();
    productModelList.shuffle();

    // Initially, set filtered products to all products
    filteredProducts = List.from(productModelList);

    setState(() {
      isLoading = false;
    });
  }

  TextEditingController search = TextEditingController();
  List<ProductModel> searchList = [];

  void searchProduct(String value) {
    searchList = filteredProducts
        .where((element) =>
            element.name.toLowerCase().contains(value.toLowerCase()))
        .toList();
    setState(() {});
  }

  void showFilterOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Apply the filter and update the filtered products
            void applyFilters() {
              // Kiểm tra xem có bất kỳ bộ lọc nào được bật không
              bool anyFilterSelected = priceFilters.values.contains(true);

              // Nếu không có bộ lọc nào được bật, hiển thị toàn bộ danh sách sản phẩm
              if (!anyFilterSelected) {
                setState(() {
                  filteredProducts = List.from(productModelList);
                  searchList = filteredProducts; // Cập nhật searchList
                });
              } else {
                // Áp dụng bộ lọc như bình thường
                List<ProductModel> tempFilteredProducts = productModelList.where((product) {
                  int price = int.parse(product.price);
                  if (priceFilters['< 1.000.000 VND'] == true && price < 1000000)
                    return true;
                  if (priceFilters['1.000.000 VND - 5.000.000 VND'] == true &&
                      price >= 1000000 &&
                      price <= 5000000) return true;
                  if (priceFilters['5.000.000 VND - 15.000.000 VND'] == true &&
                      price > 5000000 &&
                      price <= 15000000) return true;
                  if (priceFilters['15.000.000 VND - 30.000.000 VND'] == true &&
                      price > 15000000 &&
                      price <= 30000000) return true;
                  if (priceFilters['30.000.000 VND - 50.000.000 VND'] == true &&
                      price > 30000000 &&
                      price <= 50000000) return true;
                  if (priceFilters['> 50.000.000 VND'] == true && price > 50000000)
                    return true;
                  return false;
                }).toList();

                setState(() {
                  filteredProducts = tempFilteredProducts;
                  searchList = filteredProducts; // Cập nhật searchList
                });
              }
              Navigator.pop(context); // Đóng hộp thoại sau khi áp dụng lọc
            }

            return AlertDialog(
              title: Text(
                'Filter by Price',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Loop through the price filters and create a checkbox for each range
                    ...priceFilters.keys.map((priceRange) {
                      return CheckboxListTile(
                        title: Text(priceRange),
                        value: priceFilters[priceRange],
                        onChanged: (value) {
                          setModalState(() {
                            priceFilters[priceRange] =
                                value!; // Update the state of the checkbox
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: applyFilters,
                    // Call applyFilters when the button is pressed
                    child: Text('Apply Filters'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context);
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
          : RefreshIndicator(
              onRefresh: getCategoryList,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            'Welcome, ${appProvider.getUserInformation.name}',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffff4242),
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: search,
                                  onChanged: (value) {
                                    searchProduct(value);
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search ... ',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              IconButton(
                                onPressed: showFilterOptions,
                                icon: Icon(
                                  Icons.filter_alt_outlined,
                                  size: 35,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    categoriesList.isEmpty
                        ? Center(child: Text('Categories are empty'))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: categoriesList.map((category) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12.0, right: 12.0),
                                  child: CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      Routes.instance.push(
                                        widget: CategoryView(
                                            categoryModel: category),
                                        context: context,
                                      );
                                    },
                                    child: Card(
                                      color: Colors.white,
                                      elevation: 6,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: SizedBox(
                                        height: 120,
                                        width: 120,
                                        child: category.image == ''
                                            ? CircularProgressIndicator()
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.network(
                                                    category.image)),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        'All Products',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    search.text.isNotEmpty && searchList.isEmpty
                        ? Center(child: Text('No Product Found'))
                        : (searchList.isEmpty && search.text.isEmpty)
                            ? buildProductGrid(filteredProducts)
                            : buildProductGrid(searchList),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildProductGrid(List<ProductModel> products) {
    AppProvider appProvider = Provider.of<AppProvider>(context);
    String formatPrice(String price) {
      int priceInt = int.tryParse(price) ?? 0;
      return priceInt.toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (Match m) => "${m[0]}.",
          );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        primary: false,
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (ctx, index) {
          ProductModel singleProduct = products[index];
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffff4242), Color(0xffefd7dc)],
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
                        ? CircularProgressIndicator()
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
                    Text('Price: ${formatPrice(singleProduct.price)} VND'),
                    SizedBox(height: 12),
                    SizedBox(
                      height: 45,
                      width: 140,
                      child: OutlinedButton(
                        onPressed: () {
                          Routes.instance.push(
                              widget: ProductDetails(
                                singleProduct: singleProduct,
                                userModel: appProvider.getUserInformation,
                              ),
                              context: context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          surfaceTintColor: Colors.white,
                          shadowColor: Colors.white,
                          side: BorderSide(color: Colors.white, width: 2),
                          disabledForegroundColor:
                              Colors.white.withOpacity(0.38),
                        ),
                        child: Text(
                          'Buy',
                          style: TextStyle(color: Colors.white),
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
    );
  }
}
