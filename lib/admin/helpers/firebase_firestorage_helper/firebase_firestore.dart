import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_lien_nganh/admin/constants/constants.dart';
import 'package:do_an_lien_nganh/admin/helpers/firebase_storage_helper/firebase_storage_helper.dart';
import 'package:do_an_lien_nganh/admin/models/category_model/category_model.dart';
import 'package:do_an_lien_nganh/admin/models/order_model/order_model.dart';
import 'package:do_an_lien_nganh/admin/models/product_model/product_model.dart';
import 'package:do_an_lien_nganh/admin/models/user_model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseFirestoreHelper {
  static FirebaseFirestoreHelper instance = FirebaseFirestoreHelper();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<List<UserModel>> getUserList() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _firebaseFirestore.collection("users").get();

      List<UserModel> userModelList = querySnapshot.docs
          .map((e) => UserModel.fromJson(e.data()))
          .toList();

      return userModelList;
    } catch (e) {
      print("Error fetching user list: $e");
      return []; // Return an empty list if there's an error
    }
  }


  Future<List<CategoryModel>> getCategoriesList() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _firebaseFirestore.collection('categories').get();
      List<CategoryModel> categoriesList = querySnapshot.docs
          .map((e) => CategoryModel.fromJson(e.data()))
          .toList();
      return categoriesList;
    } catch (e) {
      showMessage(e.toString());
      return [];
    }
  }

  ////user

  Future<String> deleteSingleUser(String uid) async {
    try {
      // Delete user from Firestore using UID
      await _firebaseFirestore.collection("users").doc(uid).delete();

      // Delete user from Firebase Authentication
      await FirebaseAuth.instance.currentUser!.delete();

      return "Successfully Deleted";
    } catch (e) {
      return e.toString();
    }
  }

  ////category

  Future<String> deleteSingleCategory(String id) async {
    try {
      await _firebaseFirestore.collection("categories").doc(id).delete();
      return "Successfully Deleted";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> updateSingleCategory(CategoryModel categoryModel) async {
    try {
      await _firebaseFirestore
          .collection("categories")
          .doc(categoryModel.id)
          .update(categoryModel.toJson());
    } catch (e) {}
  }

  Future<CategoryModel> addSingleCategory(File image, String name) async {
    DocumentReference docRef =
        _firebaseFirestore.collection("categories").doc();
    String docId = docRef.id;
    String imageUrl =
        await FirebaseStorageHelper.instance.uploadCategoryImage(docId, image);
    CategoryModel addCategory =
        CategoryModel(image: imageUrl, id: docId, name: name);
    await docRef.set(addCategory.toJson());
    return addCategory;
  }

  ////product

  Future<List<ProductModel>> getProductsList() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await _firebaseFirestore.collectionGroup("products").get();
    List<ProductModel> productModel =
        querySnapshot.docs.map((e) => ProductModel.fromJson(e.data())).toList();
    return productModel;
  }

  Future<String> deleteProduct(String categoryId, String productId) async {
    try {
      await _firebaseFirestore
          .collection("categories")
          .doc(categoryId)
          .collection("products")
          .doc(productId)
          .delete();
      return "Successfully Deleted";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> updateSingleProduct(ProductModel productModel) async {
    try {
      await _firebaseFirestore
          .collection("categories")
          .doc(productModel.categoryId)
          .collection("products")
          .doc(productModel.id)
          .update(productModel.toJson());
    } catch (e) {}
  }

  Future<ProductModel> addSingleProduct(File image, String name,
      String categoryId, String price, String description, int qty) async {
    DocumentReference docRef = _firebaseFirestore
        .collection("categories")
        .doc(categoryId)
        .collection("products")
        .doc();
    String docId = docRef.id;
    String imageUrl =
        await FirebaseStorageHelper.instance.uploadCategoryImage(docId, image);
    ProductModel addProduct = ProductModel(
        image: imageUrl,
        id: docId,
        name: name,
        categoryId: categoryId,
        price: price,
        description: description,
        isFavorite: false,
        qty: qty);
    await docRef.set(addProduct.toJson());
    return addProduct;
  }

  Future<List<OrderModel>> getCompletedOrder() async {
    QuerySnapshot<Map<String, dynamic>> completedOrder =
        await _firebaseFirestore
            .collection("orders")
            .where("status", isEqualTo: 'completed')
            .get();
    List<OrderModel> completedOrderList =
        completedOrder.docs.map((e) => OrderModel.fromJson(e.data())).toList();
    return completedOrderList;
  }

  Future<List<OrderModel>> getCanceledOrder() async {
    QuerySnapshot<Map<String, dynamic>> canceledOrder = await _firebaseFirestore
        .collection("orders")
        .where("status", isEqualTo: 'cancel')
        .get();
    List<OrderModel> canceledOrderList =
        canceledOrder.docs.map((e) => OrderModel.fromJson(e.data())).toList();
    return canceledOrderList;
  }

  Future<List<OrderModel>> getPendingOrder() async {
    QuerySnapshot<Map<String, dynamic>> pendingOrder = await _firebaseFirestore
        .collection("orders")
        .where("status", isEqualTo: 'pending')
        .get();
    List<OrderModel> pendingOrderList =
        pendingOrder.docs.map((e) => OrderModel.fromJson(e.data())).toList();
    return pendingOrderList;
  }

  Future<List<OrderModel>> getDeliveryOrder() async {
    QuerySnapshot<Map<String, dynamic>> deliveryOrder = await _firebaseFirestore
        .collection("orders")
        .where("status", isEqualTo: 'delivery')
        .get();
    List<OrderModel> deliveryOrderList =
        deliveryOrder.docs.map((e) => OrderModel.fromJson(e.data())).toList();
    return deliveryOrderList;
  }

  Future<void> updateOrder(OrderModel orderModel, String status) async {
    await _firebaseFirestore
        .collection('usersOrders')
        .doc(orderModel.userId)
        .collection('orders')
        .doc(orderModel.orderId)
        .update({"status": status});

    await _firebaseFirestore
        .collection('orders')
        .doc(orderModel.orderId)
        .update({"status": status});
  }
}
