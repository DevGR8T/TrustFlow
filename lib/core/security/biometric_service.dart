import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';

enum BiometricStatus {
  success,
  failed,
  notAvailable,
  notEnrolled,
  lockedOut,
  cancelled,
}

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> isEnrolled() async {
    try {
      final biometrics = await _auth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<BiometricStatus> authenticate() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      if (!isSupported) return BiometricStatus.notAvailable;

      final biometrics = await _auth.getAvailableBiometrics();
      if (biometrics.isEmpty) return BiometricStatus.notEnrolled;

      final authenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to access TrustFlow',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return authenticated ? BiometricStatus.success : BiometricStatus.failed;
    } on PlatformException catch (e) {
      switch (e.code) {
        case auth_error.notAvailable:
          return BiometricStatus.notAvailable;
        case auth_error.notEnrolled:
          return BiometricStatus.notEnrolled;
        case auth_error.lockedOut:
        case auth_error.permanentlyLockedOut:
          return BiometricStatus.lockedOut;
        default:
          return BiometricStatus.cancelled;
      }
    }
  }
}