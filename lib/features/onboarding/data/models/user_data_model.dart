import 'dart:convert';
import '../../domain/entities/user_data.dart';

/// User Data Model
/// Extends UserData entity with JSON serialization
class UserDataModel extends UserData {
  const UserDataModel({
    String? fullName,
    String? dateOfBirth,
    String? phoneNumber,
    String? email,
    String? bvn,
  }) : super(
          fullName: fullName,
          dateOfBirth: dateOfBirth,
          phoneNumber: phoneNumber,
          email: email,
          bvn: bvn,
        );

  /// Create from UserData entity
  factory UserDataModel.fromEntity(UserData entity) {
    return UserDataModel(
      fullName: entity.fullName,
      dateOfBirth: entity.dateOfBirth,
      phoneNumber: entity.phoneNumber,
      email: entity.email,
      bvn: entity.bvn,
    );
  }

  /// Create from JSON
  factory UserDataModel.fromJson(String source) {
    return UserDataModel.fromMap(json.decode(source));
  }

  /// Create from Map
  factory UserDataModel.fromMap(Map<String, dynamic> map) {
    return UserDataModel(
      fullName: map['fullName'],
      dateOfBirth: map['dateOfBirth'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      bvn: map['bvn'],
    );
  }

  /// Convert to JSON
  String toJson() => json.encode(toMap());

  @override
  UserDataModel copyWith({
    String? fullName,
    String? dateOfBirth,
    String? phoneNumber,
    String? email,
    String? bvn,
  }) {
    return UserDataModel(
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      bvn: bvn ?? this.bvn,
    );
  }
}