import 'dart:io';

import 'package:do_an_lien_nganh/admin/constants/constants.dart';
import 'package:do_an_lien_nganh/admin/helpers/firebase_firestorage_helper/firebase_firestore.dart';
import 'package:do_an_lien_nganh/admin/models/category_model/category_model.dart';
import 'package:do_an_lien_nganh/admin/models/order_model/order_model.dart';
import 'package:do_an_lien_nganh/admin/models/product_model/product_model.dart';
import 'package:do_an_lien_nganh/admin/models/user_model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AdminAppProvider with ChangeNotifier {
  List<UserModel> _userList = [];

  Future<void> getUserListFun() async {
    try {
      _userList = await FirebaseFirestoreHelper.instance.getUserList();
      notifyListeners(); // Notify only when data retrieval is successful
    } catch (e) {
      print("Error fetching user list: $e");
      showMessage("Error fetching user list");
    }
  }

  List<UserModel> get getUserList => _userList;

  List<CategoryModel> _categoriesList = [];

  Future<void> getCategoriesListFun() async {
    try {
      _categoriesList = await FirebaseFirestoreHelper.instance.getCategoriesList();
      notifyListeners();
    } catch (e) {
      print("Error fetching categories: $e");
      showMessage("Error fetching categories");
    }
  }

  List<CategoryModel> get getCategoriesList => _categoriesList;

  ////user deletion and admin re-login
  Future<void> deleteUserFromFirebase(UserModel userModel, String adminEmail, String adminPassword) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userModel.email,
        password: userModel.password,
      );

      String value = await FirebaseFirestoreHelper.instance.deleteSingleUser(userModel.id);
      if (value == "Successfully Deleted") {
        _userList.remove(userModel);
        showMessage("Successfully Deleted");
      } else {
        showMessage("Error: $value");
      }

      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
    } catch (e) {
      print("Error deleting user: $e");
      showMessage("Error deleting user");
    }
    notifyListeners();
  }

  ////category management
  Future<void> deleteCategoryFromFirebase(CategoryModel categoryModel) async {
    try {
      String value = await FirebaseFirestoreHelper.instance.deleteSingleCategory(categoryModel.id);
      if (value == "Successfully Deleted") {
        _categoriesList.remove(categoryModel);
        showMessage("Successfully Deleted");
      }
    } catch (e) {
      print("Error deleting category: $e");
      showMessage("Error deleting category");
    }
    notifyListeners();
  }

  void updateCategoryList(int index, CategoryModel categoryModel) async {
    try {
      await FirebaseFirestoreHelper.instance.updateSingleCategory(categoryModel);
      _categoriesList[index] = categoryModel;
      notifyListeners();
    } catch (e) {
      print("Error updating category: $e");
      showMessage("Error updating category");
    }
  }

  void addCategoryList(File image, String name) async {
    try {
      CategoryModel categoryModel = await FirebaseFirestoreHelper.instance.addSingleCategory(image, name);
      _categoriesList.add(categoryModel);
      notifyListeners();
    } catch (e) {
      print("Error adding category: $e");
      showMessage("Error adding category");
    }
  }

  ////product management
  List<ProductModel> _productList = [];

  List<ProductModel> get getProductList => _productList;

  Future<void> getProductsList() async {
    try {
      _productList = await FirebaseFirestoreHelper.instance.getProductsList();
      notifyListeners();
    } catch (e) {
      print("Error fetching products: $e");
      showMessage("Error fetching products");
    }
  }

  Future<void> deleteProductFromFirebase(ProductModel productModel) async {
    try {
      String value = await FirebaseFirestoreHelper.instance.deleteProduct(productModel.categoryId, productModel.id);
      if (value == "Successfully Deleted") {
        _productList.remove(productModel);
        showMessage("Successfully Deleted");
      }
    } catch (e) {
      print("Error deleting product: $e");
      showMessage("Error deleting product");
    }
    notifyListeners();
  }

  void updateProductList(int index, ProductModel productModel) async {
    try {
      await FirebaseFirestoreHelper.instance.updateSingleProduct(productModel);
      _productList[index] = productModel;
      notifyListeners();
    } catch (e) {
      print("Error updating product: $e");
      showMessage("Error updating product");
    }
  }

  void addProductList(File image, String name, String categoryId, String price, String description, int qty) async {
    try {
      ProductModel productModel = await FirebaseFirestoreHelper.instance.addSingleProduct(image, name, categoryId, price, description, qty);
      _productList.add(productModel);
      notifyListeners();
    } catch (e) {
      print("Error adding product: $e");
      showMessage("Error adding product");
    }
  }

  ////completed order management
  double _totalEarning = 0.0;
  List<OrderModel> _completedOrder = [];

  Future<void> geCompletedOrder() async {
    try {
      _completedOrder = await FirebaseFirestoreHelper.instance.getCompletedOrder();
      _totalEarning = _completedOrder.fold(0.0, (sum, order) => sum + order.totalPrice);
      notifyListeners();
    } catch (e) {
      print("Error fetching completed orders: $e");
      showMessage("Error fetching completed orders");
    }
  }

  double get getTotalEarning => _totalEarning;
  List<OrderModel> get geCompletedOrderList => _completedOrder;

  List<OrderModel> _canceledOrder = [];

  Future<void> getCanceledOrder() async {
    try {
      _canceledOrder = await FirebaseFirestoreHelper.instance.getCanceledOrder();
      notifyListeners();
    } catch (e) {
      print("Error fetching canceled orders: $e");
      showMessage("Error fetching canceled orders");
    }
  }

  List<OrderModel> get getCanceledOrderList => _canceledOrder;

  List<OrderModel> _pendingOrder = [];

  Future<void> getPendingOrder() async {
    try {
      _pendingOrder = await FirebaseFirestoreHelper.instance.getPendingOrder();
      notifyListeners();
    } catch (e) {
      print("Error fetching pending orders: $e");
      showMessage("Error fetching pending orders");
    }
  }

  List<OrderModel> get getPendingOrderList => _pendingOrder;

  List<OrderModel> _deliveryOrder = [];

  Future<void> getDeliveryOrder() async {
    try {
      _deliveryOrder = await FirebaseFirestoreHelper.instance.getDeliveryOrder();
      notifyListeners();
    } catch (e) {
      print("Error fetching delivery orders: $e");
      showMessage("Error fetching delivery orders");
    }
  }

  List<OrderModel> get getDeliveryOrderList => _deliveryOrder;

  void updatePendingOrder(OrderModel order){
    _deliveryOrder.add(order);
    _pendingOrder.remove(order);
    notifyListeners();
    showMessage("Send to delivery");
  }

  void updateCancelPendingOrder(OrderModel order){
    _canceledOrder.add(order);
    _pendingOrder.remove(order);
    notifyListeners();
    showMessage("Successfully cancel");
  }

  void updateCancelDeliveryOrder(OrderModel order){
    _canceledOrder.add(order);
    _deliveryOrder.remove(order);
    notifyListeners();
    showMessage("Successfully cancel");
  }

  ///callback
  Future<void> callBackFunction() async {
    await getUserListFun();
    await getCategoriesListFun();
    await getProductsList();
    await geCompletedOrder();
    await getCanceledOrder();
    await getPendingOrder();
    await getDeliveryOrder();
  }
}
