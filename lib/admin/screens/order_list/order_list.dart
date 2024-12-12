import 'package:do_an_lien_nganh/admin/models/order_model/order_model.dart';
import 'package:do_an_lien_nganh/admin/screens/home_page/home_page.dart';
import 'package:do_an_lien_nganh/admin/widgets/single_order_widget/single_order_widget.dart';
import 'package:do_an_lien_nganh/user/models/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:do_an_lien_nganh/admin/helpers/firebase_firestorage_helper/firebase_firestore.dart';

class OrderList extends StatefulWidget {
  const OrderList({
    super.key,
    required this.title,
    required this.orderStatus,
  });

  final String title;
  final String orderStatus;

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  late Future<List<OrderModel>> _orderFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    switch (widget.orderStatus) {
      case 'completed':
        _orderFuture = FirebaseFirestoreHelper.instance.getCompletedOrder();
        break;
      case 'cancel':
        _orderFuture = FirebaseFirestoreHelper.instance.getCanceledOrder();
        break;
      case 'pending':
        _orderFuture = FirebaseFirestoreHelper.instance.getPendingOrder();
        break;
      case 'delivery':
        _orderFuture = FirebaseFirestoreHelper.instance.getDeliveryOrder();
        break;
      default:
        throw Exception('Invalid order status');
    }
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.title} Orders List',
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
            Routes.instance.pushAndRemoveUntil(widget: HomePage(), context: context);
          },
        ),
      ),
      body: FutureBuilder<List<OrderModel>>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No orders found"));
          }

          return RefreshIndicator(
            onRefresh: _refreshOrders,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  OrderModel orderModel = snapshot.data![index];
                  return SingleOrderWidget(
                    orderModel: orderModel,
                    onOrderUpdated: _refreshOrders,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}