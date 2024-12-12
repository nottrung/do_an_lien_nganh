import 'package:do_an_lien_nganh/admin/provider/app_provider.dart';
import 'package:do_an_lien_nganh/admin/screens/categories_view/categories_view.dart';
import 'package:do_an_lien_nganh/admin/screens/home_page/widgets/single_dash_item.dart';
import 'package:do_an_lien_nganh/admin/screens/product_view/product_view.dart';
import 'package:do_an_lien_nganh/admin/screens/user_view/user_view.dart';
import 'package:do_an_lien_nganh/user/models/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../earning_screen/earning_screen.dart';
import '../order_list/order_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    AdminAppProvider appProvider =
        Provider.of<AdminAppProvider>(context, listen: false);
    await appProvider.callBackFunction();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    AdminAppProvider appProvider = Provider.of<AdminAppProvider>(context);

    String formatPrice(int price) {
      return price.toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (Match m) => "${m[0]}.",
          );
    }

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Admin Control',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage:
                                AssetImage('assets/images/user-profile.jpg'),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Admin',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      SingleDashItem(
                        title:
                            '${formatPrice(appProvider.getTotalEarning.toInt())} VND',
                        subtitle: "Earning",
                        onPressed: () {
                          Routes.instance.push(widget: EarningScreen(), context: context);
                        },
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        primary: false,
                        padding: EdgeInsets.only(top: 12, bottom: 12),
                        crossAxisCount: 2,
                        children: [
                          SingleDashItem(
                              title: appProvider.getUserList.length.toString(),
                              onPressed: () {
                                Routes.instance
                                    .push(widget: UserView(), context: context);
                              },
                              subtitle: "Users"),
                          SingleDashItem(
                              title: appProvider.getCategoriesList.length
                                  .toString(),
                              onPressed: () {
                                Routes.instance.push(
                                    widget: CategoriesView(), context: context);
                              },
                              subtitle: "Categories"),
                          SingleDashItem(
                            title: appProvider.getProductList.length.toString(),
                            subtitle: "Products",
                            onPressed: () {
                              Routes.instance.push(
                                  widget: ProductView(), context: context);
                            },
                          ),
                          SingleDashItem(
                            title: appProvider.getPendingOrderList.length
                                .toString(),
                            subtitle: "Pending Order",
                            onPressed: () {
                              Routes.instance.push(
                                  widget: OrderList(
                                    title: 'Pending',
                                    orderStatus: 'pending',
                                  ),
                                  context: context);
                            },
                          ),
                          SingleDashItem(
                            title: appProvider.getDeliveryOrderList.length
                                .toString(),
                            subtitle: "Delivery Order",
                            onPressed: () {
                              Routes.instance.push(
                                  widget: OrderList(
                                    title: 'Delivery',
                                    orderStatus: 'delivery',
                                  ),
                                  context: context);
                            },
                          ),
                          SingleDashItem(
                            title: appProvider.geCompletedOrderList.length
                                .toString(),
                            subtitle: "Completed Order",
                            onPressed: () {
                              Routes.instance.push(
                                  widget: OrderList(
                                    title: 'Completed',
                                    orderStatus: 'completed',
                                  ),
                                  context: context);
                            },
                          ),
                          SingleDashItem(
                            title: appProvider.getCanceledOrderList.length
                                .toString(),
                            subtitle: "Cancel Order",
                            onPressed: () {
                              Routes.instance.push(
                                  widget: OrderList(
                                    title: 'Cancel',
                                    orderStatus: 'cancel',
                                  ),
                                  context: context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
