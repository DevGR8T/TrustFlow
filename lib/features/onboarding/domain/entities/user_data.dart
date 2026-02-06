// User Data Entity
// Represents user information captured during onboarding

class UserData {
  final String? fullName;
  final String? dateOfBirth;
  final String? phoneNumber;
  final String? email;
  final String? bvn;

  const UserData({
    this.fullName,
    this.dateOfBirth,
    this.phoneNumber,
    this.email,
    this.bvn,
  });

  /// Create a copy with updated fields
  UserData copyWith({
    String? fullName,
    String? dateOfBirth,
    String? phoneNumber,
    String? email,
    String? bvn,
  }) {
    return UserData(
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      bvn: bvn ?? this.bvn,
    );
  }

  /// Convert to Map (for storage/transmission)
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'email': email,
      'bvn': bvn,
    };
  }

  /// Create from Map
  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      fullName: map['fullName'],
      dateOfBirth: map['dateOfBirth'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      bvn: map['bvn'],
    );
  }

  @override
  String toString() {
    return 'UserData(fullName: $fullName, phone: $phoneNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserData &&
        other.fullName == fullName &&
        other.dateOfBirth == dateOfBirth &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.bvn == bvn;
  }

  @override
  int get hashCode {
    return fullName.hashCode ^
        dateOfBirth.hashCode ^
        phoneNumber.hashCode ^
        email.hashCode ^
        bvn.hashCode;
  }
}