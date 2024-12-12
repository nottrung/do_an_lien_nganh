import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_lien_nganh/user/firebase_helper/firebase_firestorage_helper/firebase_firestore.dart';
import 'package:do_an_lien_nganh/user/models/order_model/order_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Future<List<OrderModel>> _orderFuture;

  @override
  void initState() {
    super.initState();
    _orderFuture = FirebaseFirestoreHelper.instance.getUserOrder();
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _orderFuture = FirebaseFirestoreHelper.instance.getUserOrder();
    });
  }

  @override
  Widget build(BuildContext context) {
    String formatPrice(int price) {
      return price.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (Match m) => "${m[0]}.",
      );
    }

    String formatDateTime(dynamic dateTime) {
      if (dateTime is Timestamp) {
        dateTime = dateTime.toDate();
      }
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          color: Colors.red,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "My Orders",
          style: TextStyle(
            color: Colors.red,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<OrderModel>>(
          future: _orderFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Image.asset('assets/images/Empty_cart.jpg'),
              );
            }

            return ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  OrderModel orderModel = snapshot.data![index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      collapsedShape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.red, width: 2.3)),
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.red, width: 2.3)),
                      title: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Container(
                              height: 200,
                              width: 140,
                              color: Colors.red.withOpacity(0.5),
                              child: Image.network(
                                orderModel.products[0].image,
                              ),
                            ),
                          ),
                          Container(
                            height: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  orderModel.products[0].name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                orderModel.products.length > 1
                                    ? SizedBox()
                                    : Column(
                                  children: [
                                    Text(
                                      'Quantity: ${orderModel.products[0].qty.toString()}',
                                    ),
                                  ],
                                ),
                                Text(
                                  '${formatPrice(orderModel.totalPrice.toInt())} VND',
                                ),
                                Text(
                                  'Status: ${orderModel.status}',
                                  style: TextStyle(fontSize: 12),
                                ),
                                orderModel.status == "pending" ||
                                    orderModel.status == "delivery"
                                    ? ElevatedButton(
                                  onPressed: () async {
                                    await FirebaseFirestoreHelper.instance
                                        .updateOrder(orderModel, 'cancel');
                                    orderModel.status = 'cancel';
                                    _refreshOrders();
                                  },
                                  child: Text("Cancel Order", style: TextStyle(color: Colors.white),),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                )
                                    : SizedBox.fromSize(),
                                orderModel.status == "delivery"
                                    ? ElevatedButton(
                                  onPressed: () async {
                                    await FirebaseFirestoreHelper.instance
                                        .updateOrder(orderModel, 'completed');
                                    orderModel.status = 'completed';
                                    _refreshOrders();
                                  },
                                  child: Text('Delivery Order'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(
                                        color: Colors.red, width: 1.7),
                                  ),
                                )
                                    : SizedBox.fromSize(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      children: orderModel.products.length > 1
                          ? [
                        Text(
                          'Details',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Divider(color: Colors.red),
                        ...orderModel.products.map((singleProduct) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 15, bottom: 10, right: 15),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10.0),
                                      child: Container(
                                        height: 90,
                                        width: 90,
                                        color: Colors.red.withOpacity(0.5),
                                        child: Image.network(
                                          singleProduct.image,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 80,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            singleProduct.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Quantity: ${singleProduct.qty.toString()}',
                                          ),
                                          Text(
                                            '${singleProduct.price.toString()} VND',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(color: Colors.red),
                              ],
                            ),
                          );
                        }).toList(),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${orderModel.name}'),
                              Divider(color: Colors.red),
                              Text('Phone: ${orderModel.phone}'),
                              Divider(color: Colors.red),
                              Text('Address: ${orderModel.address}'),
                              Divider(color: Colors.red),
                              Text(
                                'Order Date: ${formatDateTime(orderModel.orderDate)}',
                              ),
                            ],
                          ),
                        ),
                      ]
                          : [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${orderModel.name}'),
                              Divider(color: Colors.red),
                              Text('Phone: ${orderModel.phone}'),
                              Divider(color: Colors.red),
                              Text('Address: ${orderModel.address}'),
                              Divider(color: Colors.red),
                              Text(
                                'Order Date: ${formatDateTime(orderModel.orderDate)}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                });
          }),
    );
  }
}
