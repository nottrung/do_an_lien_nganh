import 'package:do_an_lien_nganh/admin/models/user_model/user_model.dart';
import 'package:do_an_lien_nganh/admin/provider/app_provider.dart';
import 'package:do_an_lien_nganh/admin/screens/user_view/widgets/single_user_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {

  @override
  void initState() {
    // TODO: implement initState
    Provider.of<AdminAppProvider>(context, listen: false).getUserListFun();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User View',
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
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Consumer<AdminAppProvider>(builder: (context, value, child) {
        return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: value.getUserList.length,
            itemBuilder: (context, index) {
              UserModel userModel = value.getUserList[index];
              return SingleUserCard(
                  userModel: userModel);
            });
      }),
    );
  }
}
