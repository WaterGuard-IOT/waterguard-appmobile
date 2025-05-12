// lib/data/models/user_model.dart
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String name,
    required String role,
    required String email,
    required String phoneNumber,
    required List<String> preferredNotifications,
    required List<String> managedTanks,
  }) : super(
    id: id,
    name: name,
    role: role,
    email: email,
    phoneNumber: phoneNumber,
    preferredNotifications: preferredNotifications,
    managedTanks: managedTanks,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      preferredNotifications: List<String>.from(json['preferredNotifications']),
      managedTanks: List<String>.from(json['managedTanks']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'email': email,
      'phoneNumber': phoneNumber,
      'preferredNotifications': preferredNotifications,
      'managedTanks': managedTanks,
    };
  }
}