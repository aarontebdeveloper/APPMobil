import 'dart:convert';
import 'package:flutter_demo/src/Models/rol.dart';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  String? id;
  String? name;
  String? lastname;
  String? email;
  String? cedula;
  String? direccion;
  String? phone;
  String? password;
  String? sessionToken;
  String? image; // Cambiado para almacenar la URL de la imagen
  List<Rol> roles;

  User({
    this.id,
    this.name,
    this.lastname,
    this.email,
    this.cedula,
    this.direccion,
    this.phone,
    this.password,
    this.sessionToken,
    this.image, // URL de la imagen
    List<Rol>? roles,
  }) : roles = roles ?? [];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"] is int ? json['id'].toString() : json["id"] ?? '',
      name: json["name"] ?? '',
      lastname: json["lastname"] ?? '',
      email: json["email"] ?? '',
      cedula: json["cedula"] ?? '',
      direccion: json["direccion"] ?? '',
      phone: json["phone"] ?? '',
      password: json["password"] ?? '',
      sessionToken: json["session_token"] ?? '',
      image: json["image"] ?? '', // Obtener la URL de la imagen
      roles: json["roles"] == null
          ? []
          : List<Rol>.from(json["roles"].map((model) => Rol.fromJson(model))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id ?? '',
      "name": name ?? '',
      "lastname": lastname ?? '',
      "email": email ?? '',
      "cedula": cedula ?? '',
      "direccion": direccion?? '',
      "phone": phone ?? '',
      "password": password ?? '',
      "session_token": sessionToken ?? '',
      "image": image ?? '', // Almacenar la URL de la imagen
      "roles": roles.map((role) => role.toJson()).toList(),
    };
  }
}
