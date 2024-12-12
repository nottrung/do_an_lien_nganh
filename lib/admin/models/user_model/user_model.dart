import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  UserModel({
    this.image,
    this.id = '',
    this.name = '',
    this.email = '',
    this.password = '',
    this.phone = '',
    this.address = ''
  });

  String? image;
  String id;
  String name;
  String email;
  String password;
  String phone;
  String address;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"] ?? '',
    image: json["image"],
    email: json["email"] ?? '',
    name: json["name"] ?? '',
    password: json["password"] ?? '',
    phone: json["phone"] ?? '',
    address: json["address"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "name": name,
    "email": email,
    "password": password,
    "phone": phone,
    "address": address,
  };

  UserModel copyWith({
    String? name,
    String? image,
    String? phone,
    String? address,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email,
        image: image ?? this.image,
        password: password,
        phone: phone ?? this.phone,
        address: address ?? this.address,
      );
}