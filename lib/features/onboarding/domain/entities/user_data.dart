import 'package:equatable/equatable.dart';

class UserData extends Equatable {
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String phoneNumber;
  final String email;
  final String? bvn;

  const UserData({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.email,
    this.bvn,
  });

  UserData copyWith({
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? phoneNumber,
    String? email,
    String? bvn,
  }) {
    return UserData(
      firstName:   firstName   ?? this.firstName,
      lastName:    lastName    ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email:       email       ?? this.email,
      bvn:         bvn         ?? this.bvn,
    );
  }

  @override
  List<Object?> get props =>
      [firstName, lastName, dateOfBirth, phoneNumber, email, bvn];
}