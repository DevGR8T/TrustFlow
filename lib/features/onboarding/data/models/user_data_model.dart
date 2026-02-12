import '../../domain/entities/user_data.dart';

class UserDataModel extends UserData {
  const UserDataModel({
    required super.firstName,
    required super.lastName,
    required super.dateOfBirth,
    required super.phoneNumber,
    required super.email,
    super.bvn,
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      firstName:   json['first_name']   as String,
      lastName:    json['last_name']    as String,
      dateOfBirth: json['date_of_birth']as String,
      phoneNumber: json['phone_number'] as String,
      email:       json['email']        as String,
      bvn:         json['bvn']          as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'first_name':   firstName,
    'last_name':    lastName,
    'date_of_birth':dateOfBirth,
    'phone_number': phoneNumber,
    'email':        email,
    if (bvn != null) 'bvn': bvn,
  };

  factory UserDataModel.fromEntity(UserData entity) {
    return UserDataModel(
      firstName:   entity.firstName,
      lastName:    entity.lastName,
      dateOfBirth: entity.dateOfBirth,
      phoneNumber: entity.phoneNumber,
      email:       entity.email,
      bvn:         entity.bvn,
    );
  }
}