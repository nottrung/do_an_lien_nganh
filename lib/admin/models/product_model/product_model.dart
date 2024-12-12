import 'dart:convert';

ProductModel productModelFromJson(String str) =>
    ProductModel.fromJson(json.decode(str));

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
  ProductModel(
      {required this.image,
      required this.id,
      required this.categoryId,
      required this.name,
      required this.price,
      required this.description,
      required this.isFavorite,
      required this.qty});

  String image;
  String id, categoryId;
  bool isFavorite;
  String name;
  String price;
  String description;
  int qty;

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json["id"] ?? '',
        categoryId: json["categoryId"] ?? '',
        name: json["name"] ?? '',
        description: json["description"] ?? '',
        image: json["image"] ?? '', // Ensure this is not null
        isFavorite: false,
        qty: json["qty"],
        price: json["price"] ?? '0', // Ensure this is not null
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "categoryId": categoryId,
        "name": name,
        "image": image,
        "description": description,
        "isFavorite": isFavorite,
        "price": price,
        "qty": qty
      };
  ProductModel copyWith({
    String? name,
    String? id,
    String? description,
    String? image,
    String? price,
    String? categoryId,
    int? qty
  }) =>
      ProductModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        image: image ?? this.image,
        isFavorite: isFavorite,
        qty: qty ?? this.qty,
        price: price ?? this.price,
        categoryId: categoryId ?? this.categoryId,
      );
}
