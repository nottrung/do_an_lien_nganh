import 'package:do_an_lien_nganh/user/models/routes/routes.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/app_provider.dart';
import '../change_password/change_password.dart';
import '../contact_to_us/contact_to_us.dart';
import '../edit_profile/edit_profile.dart';
import '../order_screen/order_screen.dart';

class AccountScreen extends StatefulWidget {
  final VoidCallback onLogout; // Add a callback for logout

  const AccountScreen({
    super.key,
    required this.onLogout,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context);
    final userImage = appProvider.getUserInformation.image;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Account",
            style: TextStyle(
                color: Colors.red, fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            GestureDetector(
              onTap: () {
                Routes.instance.push(widget: EditProfile(), context: context);
              },
              child: Row(
                children: [
                  ClipOval(
                    child: userImage != null && userImage.isNotEmpty
                        ? Image.network(
                            userImage,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/user-profile.jpg',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Text(
                    appProvider.getUserInformation.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
                flex: 2,
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Routes.instance
                            .push(widget: OrderScreen(), context: context);
                      },
                      leading: Icon(
                        Icons.shopping_bag_outlined,
                        size: 30,
                      ),
                      title: Text(
                        'Orders',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ListTile(
                      onTap: () {
                        Routes.instance.push(widget: ContactToUs(), context: context);
                      },
                      leading: Icon(
                        Icons.headphones_outlined,
                        size: 30,
                      ),
                      title: Text(
                        'Contact to us',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ListTile(
                      onTap: () {
                        Routes.instance
                            .push(widget: ChangePassword(), context: context);
                      },
                      leading: Icon(
                        Icons.key,
                        size: 30,
                      ),
                      title: Text(
                        'Change Password',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ListTile(
                      onTap: widget.onLogout, // Call the logout function
                      leading: Icon(
                        Icons.logout,
                        size: 30,
                      ),
                      title: Text(
                        'Log Out',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
