import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_lien_nganh/user/models/user_model/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:do_an_lien_nganh/user/screens/buy_product/buy_product.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:do_an_lien_nganh/user/models/product_model/product_model.dart';
import 'package:do_an_lien_nganh/user/provider/app_provider.dart';

import '../../constants/constants.dart';
import '../../models/routes/routes.dart';

class ProductDetails extends StatefulWidget {
  final ProductModel singleProduct;
  final UserModel userModel;
  const ProductDetails(
      {super.key, required this.singleProduct, required this.userModel});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int qty = 1;
  int rating = 0;
  TextEditingController commentController = TextEditingController();
  File? selectedImage;
  bool hasCommented = false;

  @override
  void initState() {
    super.initState();
    checkIfCommentExists();
  }

  Future<void> checkIfCommentExists() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('comments')
        .doc(widget.singleProduct.id)
        .collection('all_comments')
        .where('userId', isEqualTo: widget.userModel.id)
        .get();

    setState(() {
      hasCommented = snapshot.docs.isNotEmpty;
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Rate and Comment"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              rating = index + 1;
                            });
                          },
                          icon: Icon(
                            Icons.star,
                            color: index < rating ? Colors.yellow : Colors.grey,
                          ),
                        );
                      }),
                    ),
                    Text(
                      rating == 1
                          ? 'Very disappointed'
                          : rating == 2
                          ? 'Disappointed'
                          : rating == 3
                          ? 'Neutral'
                          : rating == 4
                          ? 'Satisfied'
                          : rating == 5
                          ? 'Very satisfied'
                          : 'Select your satisfaction level',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        labelText: 'Enter your comment',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: CupertinoButton(
                        onPressed: () {
                          pickImage().then((_) {
                            setState(() {}); // Refresh dialog with selected image
                          });
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(8),
                            image: selectedImage != null
                                ? DecorationImage(
                              image: FileImage(selectedImage!),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: selectedImage == null
                              ? Icon(
                            CupertinoIcons.photo_on_rectangle,
                            color: Colors.grey,
                            size: 40,
                          )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: submitComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Comment"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> submitComment() async {
    String comment = commentController.text;
    String userId = widget.userModel.id;
    String productId = widget.singleProduct.id;

    String? imageUrl;
    if (selectedImage != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('comment/${userId}_${productId}');
      await storageRef.putFile(selectedImage!);
      imageUrl = await storageRef.getDownloadURL();
    }

    await FirebaseFirestore.instance
        .collection('comments')
        .doc(productId)
        .collection('all_comments')
        .add({
      'userId': userId,
      'productId': productId,
      'rating': rating,
      'comment': comment,
      'image_comment': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((_) {
      showMessage("Comment submitted");
      setState(() {
        commentController.clear();
        selectedImage = null;
        rating = 0;
        hasCommented = true;
      });
      Navigator.of(context, rootNavigator: true).pop();
    }).catchError((error) => showMessage("Failed to submit comment: $error"));
  }

  String formatPrice(String price) {
    int priceInt = int.tryParse(price) ?? 0;
    return priceInt.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => "${m[0]}.",
    );
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          color: Colors.red,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      widget.singleProduct.image,
                      height: 300,
                      width: 400,
                      scale: 0.5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.singleProduct.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(widget.singleProduct.description),
                    SizedBox(height: 15),
                    Text(
                      'Price: ${formatPrice(widget.singleProduct.price)} VND',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        CupertinoButton(
                          onPressed: () {
                            if (qty > 1) {
                              setState(() {
                                qty--;
                              });
                            }
                          },
                          padding: EdgeInsets.zero,
                          child: const CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.remove, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Text(
                          qty.toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        CupertinoButton(
                          onPressed: () {
                            setState(() {
                              qty++;
                            });
                          },
                          padding: EdgeInsets.zero,
                          child: const CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Divider(),
                    // Display the total number of comments and average rating
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('comments')
                          .doc(widget.singleProduct.id)
                          .collection('all_comments')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        int totalComments = snapshot.data!.docs.length;
                        double averageRating = snapshot.data!.docs
                            .map((doc) => doc['rating'] as int)
                            .fold(0, (a, b) => a + b) /
                            totalComments;

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total Comments: $totalComments",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    "Average Rating: ${averageRating.toStringAsFixed(1)} ★",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    ),
                    // Display all comments with user profile
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('comments')
                            .doc(widget.singleProduct.id)
                            .collection('all_comments')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Text("No comments available");
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var commentData = snapshot.data!.docs[index];
                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(commentData['userId'])
                                    .get(),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }
                                  var userData = userSnapshot.data;
                                  return Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ClipOval(
                                            child: userData != null &&
                                                userData['image'] != null
                                                ? Image.network(
                                              userData['image'],
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            )
                                                : Icon(Icons.person, size: 50),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            userData != null
                                                ? userData['name']
                                                : 'Anonymous',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: List.generate(
                                          5,
                                              (starIndex) => Icon(
                                            Icons.star,
                                            color: starIndex <
                                                commentData['rating']
                                                ? Colors.yellow
                                                : Colors.grey,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(commentData['comment']),
                                      const SizedBox(height: 5),
                                      commentData['image_comment'] != null
                                          ? Image.network(
                                        commentData['image_comment'],
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      )
                                          : Container(),
                                      const Divider(),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if (!hasCommented)
                      Center(
                        child: ElevatedButton(
                          onPressed: showCommentDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Comment"),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      ProductModel productModel =
                      widget.singleProduct.copyWith(qty: qty);
                      appProvider.addCartProduct(productModel);
                      showMessage("Added to Cart");
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 2),
                      foregroundColor: Colors.red,
                    ),
                    child: const Text("ADD TO CART"),
                  ),
                  const SizedBox(width: 24.0),
                  ElevatedButton(
                    onPressed: () {
                      ProductModel productModel =
                      widget.singleProduct.copyWith(qty: qty);
                      appProvider.addCheckoutProduct(productModel);
                      Routes.instance.push(
                        widget: CheckOut(singleProduct: productModel),
                        context: context,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("BUY PRODUCT"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
