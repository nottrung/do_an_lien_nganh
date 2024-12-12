import 'dart:convert';

ProductModel productModelFromJson(String str) =>
    ProductModel.fromJson(json.decode(str));

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
  ProductModel(
      {required this.image,
      required this.id,
      required this.name,
      required this.price,
      required this.description,
      required this.isFavorite,
      this.qty});

  String image;
  String id;
  bool isFavorite;
  String name;
  String price;
  String description;
  int? qty;

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json["id"] ?? '',
    name: json["name"] ?? '',
    description: json["description"] ?? '',
    image: json["image"] ?? '', // Ensure this is not null
    isFavorite: false,
    qty: json["qty"],
    price: json["price"] ?? '0', // Ensure this is not null
  );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "description": description,
        "isFavorite": isFavorite,
        "price": price,
        "qty": qty
      };

  ProductModel copyWith({
    int? qty,
  }) =>
      ProductModel(
        id: id,
        name: name,
        description: description,
        image: image,
        isFavorite: isFavorite,
        qty: qty ?? this.qty,
        price: price,
      );
}
