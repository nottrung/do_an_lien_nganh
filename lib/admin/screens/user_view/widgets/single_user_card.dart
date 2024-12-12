import 'package:do_an_lien_nganh/admin/models/user_model/user_model.dart';
import 'package:do_an_lien_nganh/admin/provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SingleUserCard extends StatefulWidget {
  const SingleUserCard(
      {super.key, required this.userModel});
  final UserModel userModel;

  @override
  State<SingleUserCard> createState() => _SingleUserCardState();
}

class _SingleUserCardState extends State<SingleUserCard> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

    AdminAppProvider appProvider = Provider.of<AdminAppProvider>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipOval(
              child: widget.userModel.image != null
                  ? Image.network(
                      widget.userModel.image!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/user-profile.jpg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(
              width: 12,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.userModel.name),
                Text(widget.userModel.email),
                Text(widget.userModel.phone),
                Text(widget.userModel.address)
              ],
            ),
            Spacer(),
            isLoading
                ? CircularProgressIndicator()
                : IconButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await appProvider
                          .deleteUserFromFirebase(widget.userModel, widget.userModel.email, widget.userModel.password);
                      setState(() {
                        isLoading = false;
                      });
                    },
                    icon: Icon(Icons.delete)),
          ],
        ),
      ),
    );
    ;
  }
}
