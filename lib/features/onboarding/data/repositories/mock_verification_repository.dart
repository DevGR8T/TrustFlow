import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trust_flow/core/error/exceptions.dart';
import 'dart:convert';


/// Mock Verification Repository
/// Simulates real fintech KYC API behavior with realistic delays and failure rates
class MockVerificationRepository {
  final Random _random = Random();
  
  // Simulate network delays (in seconds)
  static const int _minDelay = 1;
  static const int _maxDelay = 3;
  
  // Success rates (industry realistic)
  static const int _bvnSuccessRate = 85; // 85% success
  static const int _documentSuccessRate = 70; // 70% success (lighting/quality issues)
  static const int _faceSuccessRate = 80; // 80% success
  static const int _finalVerificationSuccessRate = 90; // 90% approval after all steps
  
  /// Simulate random network delay
  Future<void> _simulateNetworkDelay() async {
    final delaySeconds = _minDelay + _random.nextInt(_maxDelay - _minDelay);
    await Future.delayed(Duration(seconds: delaySeconds));
  }
  
  /// Simulate random network failure (10% chance)
  void _simulateNetworkFailure() {
    if (_random.nextInt(100) < 10) {
      throw NetworkException('Network error. Please check your connection and try again.');
    }
  }
  
  // ============================================================================
  // BVN VERIFICATION
  // ============================================================================
  
  /// Verify BVN
  /// Returns user data if successful
  /// Throws exception if verification fails
  Future<Map<String, dynamic>> verifyBvn(String bvn) async {
    print('[MockAPI] Verifying BVN: $bvn');
    
    // Simulate network delay
    await _simulateNetworkDelay();
    
    // Simulate network failure
    _simulateNetworkFailure();
    
    // Validate BVN format
    if (bvn.length != 11) {
      throw ValidationException('BVN must be exactly 11 digits');
    }
    
    // Simulate BVN verification (85% success rate)
    final success = _random.nextInt(100) < _bvnSuccessRate;
    
    if (!success) {
      // Realistic failure reasons
      final failures = [
        'BVN not found in database',
        'BVN does not match the name you provided',
        'BVN has been flagged. Please contact your bank',
        'Unable to verify BVN at this time. Please try again',
      ];
      throw VerificationException(failures[_random.nextInt(failures.length)]);
    }
    
    // Success - return mock user data
    print('[MockAPI] BVN verified successfully');
    return {
      'success': true,
      'message': 'BVN verified successfully',
      'data': {
        'bvn': bvn,
        'firstName': 'John',
        'lastName': 'Doe',
        'dateOfBirth': '1990-01-15',
        'phoneNumber': '+2348012345678',
        'verified': true,
        'timestamp': DateTime.now().toIso8601String(),
      }
    };
  }
  
  // ============================================================================
  // DOCUMENT UPLOAD
  // ============================================================================
  
  /// Upload document (ID card, passport, etc.)
  /// Returns document ID if successful
  Future<Map<String, dynamic>> uploadDocument(String imagePath) async {
    print('[MockAPI] Uploading document: $imagePath');
    
    // Simulate longer delay for image upload
    await Future.delayed(Duration(seconds: 2 + _random.nextInt(3)));
    
    // Simulate network failure
    _simulateNetworkFailure();
    
    // Simulate document validation (70% success - image quality issues common)
    final success = _random.nextInt(100) < _documentSuccessRate;
    
    if (!success) {
      // Realistic document failure reasons
      final failures = [
        'Document image is too blurry. Please retake with better focus.',
        'Poor lighting detected. Please ensure document is well-lit.',
        'Document edges not visible. Please capture entire document.',
        'Text on document is not readable. Please improve image quality.',
        'Glare detected on document. Please avoid reflections.',
      ];
      throw DocumentException(failures[_random.nextInt(failures.length)]);
    }
    
    // Success
    print('[MockAPI] Document uploaded successfully');
    return {
      'success': true,
      'message': 'Document uploaded successfully',
      'data': {
        'documentId': 'DOC_${DateTime.now().millisecondsSinceEpoch}',
        'documentType': 'government_id',
        'uploadedAt': DateTime.now().toIso8601String(),
        'status': 'pending_review',
      }
    };
  }
  
  // ============================================================================
  // FACE CAPTURE
  // ============================================================================
  
  /// Upload face capture (selfie)
  /// Returns face ID if successful
  Future<Map<String, dynamic>> uploadFaceCapture(String imagePath) async {
    print('[MockAPI] Uploading face capture: $imagePath');
    
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2 + _random.nextInt(2)));
    
    // Simulate network failure
    _simulateNetworkFailure();
    
    // Simulate face validation (80% success rate)
    final success = _random.nextInt(100) < _faceSuccessRate;
    
    if (!success) {
      // Realistic face capture failure reasons
      final failures = [
        'Face not clearly visible. Please try again.',
        'Multiple faces detected. Please ensure you are alone.',
        'Face is too dark. Please improve lighting.',
        'Face is partially covered. Please remove glasses/mask.',
        'Face is too far from camera. Please move closer.',
      ];
      throw FaceException(failures[_random.nextInt(failures.length)]);
    }
    
    // Success
    print('[MockAPI] Face capture uploaded successfully');
    return {
      'success': true,
      'message': 'Face capture successful',
      'data': {
        'faceId': 'FACE_${DateTime.now().millisecondsSinceEpoch}',
        'livenessCheck': 'passed',
        'uploadedAt': DateTime.now().toIso8601String(),
        'status': 'pending_verification',
      }
    };
  }
  
  // ============================================================================
  // FINAL VERIFICATION STATUS
  // ============================================================================
  
  /// Check final verification status
  /// Simulates backend processing time
  Future<Map<String, dynamic>> checkVerificationStatus() async {
    print('[MockAPI] Checking verification status...');
    
    // Simulate longer processing time (3-5 seconds)
    await Future.delayed(Duration(seconds: 3 + _random.nextInt(3)));
    
    // Simulate network failure
    _simulateNetworkFailure();
    
    // 90% approval rate after all steps completed successfully
    final approved = _random.nextInt(100) < _finalVerificationSuccessRate;
    
    if (approved) {
      print('[MockAPI] Verification APPROVED');
      return {
        'status': 'approved',
        'message': 'Your verification has been approved! Welcome aboard.',
        'data': {
          'userId': 'USER_${DateTime.now().millisecondsSinceEpoch}',
          'verifiedAt': DateTime.now().toIso8601String(),
          'kycLevel': 'tier_2',
        }
      };
    } else {
      print('[MockAPI] Verification REJECTED');
      // Realistic rejection reasons
      final reasons = [
        'Document does not match face photo. Please ensure you submitted your own ID.',
        'Unable to verify identity. Please contact support.',
        'Information mismatch detected. Please review your details.',
      ];
      return {
        'status': 'rejected',
        'message': reasons[_random.nextInt(reasons.length)],
        'data': {
          'rejectedAt': DateTime.now().toIso8601String(),
          'canRetry': true,
        }
      };
    }
  }
  
  // ============================================================================
  // LOCAL PROGRESS STORAGE (SharedPreferences)
  // ============================================================================
  
  /// Save onboarding progress locally
  /// This ensures user can exit and resume
  Future<void> saveProgress(Map<String, dynamic> progressData) async {
    print('[MockAPI] Saving progress locally');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onboarding_progress', jsonEncode(progressData));
    print('[MockAPI] Progress saved: ${progressData.keys}');
  }
  
  /// Get saved onboarding progress
  Future<Map<String, dynamic>?> getProgress() async {
    print('[MockAPI] Retrieving saved progress');
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('onboarding_progress');
    
    if (data == null) {
      print('[MockAPI] No saved progress found');
      return null;
    }
    
    final progress = jsonDecode(data) as Map<String, dynamic>;
    print('[MockAPI] Progress retrieved: ${progress.keys}');
    return progress;
  }
  
  /// Clear saved progress (for retry or restart)
  Future<void> clearProgress() async {
    print('[MockAPI] Clearing saved progress');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_progress');
    print('[MockAPI] Progress cleared');
  }
  
  /// Check if user has saved progress
  Future<bool> hasProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('onboarding_progress');
  }
  
  // ============================================================================
  // ANALYTICS & METRICS (Optional - for tracking)
  // ============================================================================
  
  /// Log analytics event
  /// In production, this would send to Firebase Analytics, Mixpanel, etc.
  Future<void> logEvent(String eventName, Map<String, dynamic> parameters) async {
    print('[MockAPI - Analytics] Event: $eventName | Params: $parameters');
    // In production: await analytics.logEvent(name: eventName, parameters: parameters);
  }
}

