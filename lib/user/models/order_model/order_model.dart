import 'package:cloud_firestore/cloud_firestore.dart';
import '../product_model/product_model.dart';

class OrderModel {
  OrderModel({
    required this.totalPrice,
    required this.orderId,
    required this.payment,
    required this.products,
    required this.status,
    required this.address,
    required this.name,
    required this.phone,
    required this.orderDate,
    required this.userId,
  });

  String payment;
  String status;
  String address;
  String name;
  String phone;
  List<ProductModel> products;
  double totalPrice;
  String orderId;
  String userId;
  DateTime orderDate;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> productMap = json["products"];
    return OrderModel(
      userId: json["userId"],
      orderId: json["orderId"],
      products: productMap.map((e) => ProductModel.fromJson(e)).toList(),
      totalPrice: json["totalPrice"],
      status: json["status"],
      payment: json["payment"],
      address: json["address"],
      name: json["name"],
      phone: json["phone"],
      orderDate: json["orderDate"] is Timestamp
          ? (json["orderDate"] as Timestamp).toDate() // Convert Timestamp to DateTime
          : DateTime.now(),
    );
  }
}
