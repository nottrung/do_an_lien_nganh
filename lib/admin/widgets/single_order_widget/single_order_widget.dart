import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_lien_nganh/admin/helpers/firebase_firestorage_helper/firebase_firestore.dart';
import 'package:do_an_lien_nganh/admin/models/order_model/order_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../provider/app_provider.dart';

class SingleOrderWidget extends StatefulWidget {
  const SingleOrderWidget(
      {super.key, required this.orderModel, required this.onOrderUpdated});

  final OrderModel orderModel;
  final VoidCallback onOrderUpdated; // Callback to refresh orders

  @override
  State<SingleOrderWidget> createState() => _SingleOrderWidgetState();
}

class _SingleOrderWidgetState extends State<SingleOrderWidget> {
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

    AdminAppProvider appProvider =
        Provider.of<AdminAppProvider>(context, listen: false);

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        collapsedShape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.red, width: 2.3),
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.red, width: 2.3),
        ),
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Container(
                height: 200,
                width: 150,
                color: Colors.red.withOpacity(0.5),
                child: Image.network(widget.orderModel.products[0].image),
              ),
            ),
            Container(
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.orderModel.products[0].name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  widget.orderModel.products.length > 1
                      ? SizedBox()
                      : Text(
                          'Quantity: ${widget.orderModel.products[0].qty.toString()}'),
                  Text(
                      '${formatPrice(widget.orderModel.totalPrice.toInt())} VND'),
                  Text('Status: ${widget.orderModel.status}'),
                  if (widget.orderModel.status == 'pending')
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestoreHelper.instance
                            .updateOrder(widget.orderModel, 'delivery');
                        widget.orderModel.status = "delivery";
                        appProvider.updatePendingOrder(widget.orderModel);
                        widget.onOrderUpdated();
                      },
                      child: Text(
                        "Ready to Delivery",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  if (widget.orderModel.status == 'pending' ||
                      widget.orderModel.status == 'delivery')
                    ElevatedButton(
                      onPressed: () async {
                        if (widget.orderModel.status == 'pending') {
                          await FirebaseFirestoreHelper.instance
                              .updateOrder(widget.orderModel, 'cancel');
                          widget.orderModel.status = 'cancel';
                          appProvider
                              .updateCancelPendingOrder(widget.orderModel);
                          widget.onOrderUpdated();
                        } else if (widget.orderModel.status == 'delivery') {
                          await FirebaseFirestoreHelper.instance
                              .updateOrder(widget.orderModel, 'cancel');
                          widget.orderModel.status = 'cancel';
                          appProvider
                              .updateCancelDeliveryOrder(widget.orderModel);
                          widget.onOrderUpdated();
                        }
                      },
                      child: Text(
                        'Cancel Order',
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.7),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        children: widget.orderModel.products.length > 1
            ? [
                Text(
                  'Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Divider(color: Colors.red),
                ...widget.orderModel.products.map((singleProduct) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 15, bottom: 10, right: 15),
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
                                child: Image.network(singleProduct.image),
                              ),
                            ),
                            Container(
                              height: 80,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    singleProduct.name,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      'Quantity: ${singleProduct.qty.toString()}'),
                                  Text('${singleProduct.price.toString()} VND'),
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
                      Text('Name: ${widget.orderModel.name}'),
                      Divider(color: Colors.red),
                      Text('Phone: ${widget.orderModel.phone}'),
                      Divider(color: Colors.red),
                      Text('Address: ${widget.orderModel.address}'),
                      Divider(color: Colors.red),
                      Text(
                        'Order Date: ${formatDateTime(widget.orderModel.orderDate)}',
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
                      Text('Name: ${widget.orderModel.name}'),
                      Divider(color: Colors.red),
                      Text('Phone: ${widget.orderModel.phone}'),
                      Divider(color: Colors.red),
                      Text('Address: ${widget.orderModel.address}'),
                      Divider(color: Colors.red),
                      Text(
                        'Order Date: ${formatDateTime(widget.orderModel.orderDate)}',
                      ),
                    ],
                  ),
                ),
              ],
      ),
    );
  }
}
