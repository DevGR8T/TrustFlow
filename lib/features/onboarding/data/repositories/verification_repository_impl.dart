import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../domain/entities/verification_result.dart';
import '../../domain/entities/onboarding_progress.dart';
import '../../domain/entities/user_data.dart';
import '../../domain/repositories/verification_repository.dart';
import '../models/user_data_model.dart';
import '../models/verification_response_model.dart';
import 'mock_verification_repository.dart';


/// Connects domain layer to data sources (Mock API + Local Storage)
class VerificationRepositoryImpl implements VerificationRepository {
  final MockVerificationRepository _mockApi;
  static const String _progressKey = 'onboarding_progress';
  static const String _userDataKey = 'user_data';

  VerificationRepositoryImpl(this._mockApi);

  @override
  Future<VerificationResult> verifyBvn(String bvn) async {
    try {
      final response = await _mockApi.verifyBvn(bvn);
      final model = VerificationResponseModel.fromMap(response);
      return model.toEntity();
    } catch (e) {
      return VerificationResult.failure(
        message: e.toString(),
      );
    }
  }

  @override
  Future<VerificationResult> uploadDocument(String imagePath) async {
    try {
      final response = await _mockApi.uploadDocument(imagePath);
      final model = VerificationResponseModel.fromMap(response);
      return model.toEntity();
    } catch (e) {
      return VerificationResult.failure(
        message: e.toString(),
      );
    }
  }

  @override
  Future<VerificationResult> uploadFaceCapture(String imagePath) async {
    try {
      final response = await _mockApi.uploadFaceCapture(imagePath);
      final model = VerificationResponseModel.fromMap(response);
      return model.toEntity();
    } catch (e) {
      return VerificationResult.failure(
        message: e.toString(),
      );
    }
  }

  @override
  Future<VerificationResult> checkVerificationStatus() async {
    try {
      final response = await _mockApi.checkVerificationStatus();
      
      if (response['status'] == 'approved') {
        return VerificationResult.success(
          message: response['message'],
          data: response['data'],
        );
      } else {
        return VerificationResult.failure(
          message: response['message'],
          data: response['data'],
        );
      }
    } catch (e) {
      return VerificationResult.failure(
        message: e.toString(),
      );
    }
  }

  @override
  Future<void> saveProgress(
    OnboardingProgress progress,
    UserData userData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save progress
    await prefs.setString(_progressKey, jsonEncode(progress.toMap()));
    
    // Save user data
    final userModel = UserDataModel.fromEntity(userData);
    await prefs.setString(_userDataKey, userModel.toJson());
  }

  @override
  Future<OnboardingProgress?> getSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_progressKey);
    
    if (progressJson == null) return null;
    
    final progressMap = jsonDecode(progressJson) as Map<String, dynamic>;
    return OnboardingProgress.fromMap(progressMap);
  }

  @override
  Future<UserData?> getSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userDataKey);
    
    if (userJson == null) return null;
    
    return UserDataModel.fromJson(userJson);
  }

  @override
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
    await prefs.remove(_userDataKey);
  }
}