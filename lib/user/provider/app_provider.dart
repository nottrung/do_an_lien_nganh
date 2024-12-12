import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_lien_nganh/user/constants/constants.dart';
import 'package:do_an_lien_nganh/user/firebase_helper/firebase_firestorage_helper/firebase_firestore.dart';
import 'package:do_an_lien_nganh/user/firebase_helper/firebase_storage_helper/firebase_storage_helper.dart';
import 'package:do_an_lien_nganh/user/models/product_model/product_model.dart';
import 'package:do_an_lien_nganh/user/models/user_model/user_model.dart';
import 'package:flutter/cupertino.dart';

class AppProvider with ChangeNotifier {
  UserModel? _userModel;
  UserModel get getUserInformation => _userModel!;

  //checkout
  final List<ProductModel> _checkoutProductList = [];

  void addCheckoutProduct(ProductModel productModel) {
    _checkoutProductList.add(productModel);
    notifyListeners();
  }

  void removeCheckoutProduct(ProductModel productModel) {
    _checkoutProductList.remove(productModel);
    notifyListeners();
  }

  List<ProductModel> get getCheckoutProductList => _checkoutProductList;

  ///cart list

  final List<ProductModel> _cartProductList = [];

  void addCartProduct(ProductModel productModel) {
    _cartProductList.add(productModel);
    notifyListeners();
  }

  void removeCartProduct(ProductModel productModel) {
    _cartProductList.remove(productModel);
    notifyListeners();
  }

  List<ProductModel> get getCartProductList => _cartProductList;

  ///favorite list
  final List<ProductModel> _favouriteProductList = [];

  void addFavouriteProduct(ProductModel productModel) {
    _favouriteProductList.add(productModel);
    notifyListeners();
  }

  void removeFavouriteProduct(ProductModel productModel) {
    _favouriteProductList.remove(productModel);
    notifyListeners();
  }

  List<ProductModel> get getFavouriteProductList => _favouriteProductList;

  ///user info

  void getUserInfoFireBase() async {
    _userModel = await FirebaseFirestoreHelper.instance.getUserInformation();
    notifyListeners();
  }

  void updateUserInfoFirebase(
      BuildContext context, UserModel userModel, File? file) async {
    if (file == null) {
      showLoaderDialog(context);

      _userModel = userModel;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_userModel!.id)
          .set(_userModel!.toJson());
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
    } else {
      showLoaderDialog(context);
      String imageUrl =
      await FirebaseStorageHelper.instance.uploadUserImage(file);
      _userModel = userModel.copyWith(image: imageUrl);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_userModel!.id)
          .set(_userModel!.toJson());
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
    }
    showMessage("Successfully updated profile");

    notifyListeners();
  }

  //total price


  double totalPrice() {
    double totalPrice = 0.0;
    for (var element in _cartProductList) {
      double price = double.tryParse(element.price) ?? 0.0;
      totalPrice += price * (element.qty ?? 0);
    }
    return totalPrice;
  }

  double totalCheckPrice() {
    double totalCheckPrice = 0.0;
    for (var element in _checkoutProductList) {
      double price = double.tryParse(element.price) ?? 0.0;
      totalCheckPrice += price * (element.qty ?? 0);
    }
    return totalCheckPrice;
  }

  double totalBuyPrice() {
    double totalBuyPrice = 0.0;
    for (var element in _buyProductList) {
      double price = double.tryParse(element.price) ?? 0.0;
      totalBuyPrice += price * (element.qty ?? 0);
    }
    return totalBuyPrice;
  }


  //update qty
  void updateQty(ProductModel productModel, int qty){
    int index = _cartProductList.indexOf(productModel);
    _cartProductList[index].qty = qty;
    notifyListeners();
  }

  void updateCheckQty(ProductModel productModel, int qty){
    int index = _checkoutProductList.indexOf(productModel);
    _checkoutProductList[index].qty = qty;
    notifyListeners();
  }

  //Buy product

  final List<ProductModel> _buyProductList = [];

  void addBuyProduct() {
    _buyProductList.addAll(_checkoutProductList);
    notifyListeners();
  }

  void addBuyProductCartList() {
    _buyProductList.addAll(_cartProductList);
    notifyListeners();
  }

  void clearCart() {
    _cartProductList.clear();
    notifyListeners();
  }

  void clearBuyProduct() {
    _buyProductList.clear();
    notifyListeners();
  }

  List<ProductModel> get getBuyProductList => _buyProductList;
}
