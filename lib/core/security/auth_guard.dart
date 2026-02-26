import 'package:flutter/material.dart';
import 'package:trust_flow/core/di/injection_container.dart';
import 'package:trust_flow/core/security/pin_service.dart';
import 'package:trust_flow/features/auth/presentation/pin_entry_screen.dart';
import 'package:trust_flow/features/auth/presentation/pin_setup_screen.dart';


class AuthGuard extends StatefulWidget {
  final Widget child;
  const AuthGuard({Key? key, required this.child}) : super(key: key);

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  final PinService _pinService = sl<PinService>();
  bool _checking = true;
  bool _pinSet = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final pinSet = await _pinService.isPinSet();
    setState(() {
      _pinSet = pinSet;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E1A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
      );
    }

    if (!_pinSet) return const PinSetupScreen();
    return const PinEntryScreen();
  }
}