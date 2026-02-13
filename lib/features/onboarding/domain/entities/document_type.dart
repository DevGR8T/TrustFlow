import 'package:flutter/material.dart';
import '../../../../core/constants/strings.dart';

enum DocumentType {
  nin(AppStrings.docNIN, Icons.credit_card_outlined),
  passport(AppStrings.docPassport, Icons.book_outlined),
  drivers(AppStrings.docDrivers, Icons.drive_eta_outlined),
  voters(AppStrings.docVoters, Icons.how_to_vote_outlined);

  final String label;
  final IconData icon;
  const DocumentType(this.label, this.icon);

  bool get requiresBackImage => this != DocumentType.passport;
}