import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trust_flow/core/constants/colors.dart';
import 'package:trust_flow/core/di/injection_container.dart';
import 'package:trust_flow/core/security/biometric_service.dart';
import 'package:trust_flow/core/security/pin_service.dart';
import 'package:trust_flow/features/onboarding/presentation/screens/welcome_screen.dart';

class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({Key? key}) : super(key: key);

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final PinService _pinService = sl<PinService>();
  final BiometricService _biometricService = sl<BiometricService>();

  String _pin = '';
  String? _errorMessage;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await _biometricService.isAvailable();
    final enrolled = await _biometricService.isEnrolled();
    setState(() => _biometricAvailable = available && enrolled);
    if (_biometricAvailable) _authenticateWithBiometrics();
  }

  Future<void> _authenticateWithBiometrics() async {
    final status = await _biometricService.authenticate();
    if (status == BiometricStatus.success && mounted) {
      _navigateToHome();
    }
  }

  void _onKeyTap(String value) {
    HapticFeedback.lightImpact();
    if (_pin.length >= 4) return;
    setState(() {
      _errorMessage = null;
      _pin += value;
    });
    if (_pin.length == 4) _verifyPin();
  }

  void _onDelete() {
    HapticFeedback.lightImpact();
    if (_pin.isEmpty) return;
    setState(() {
      _errorMessage = null;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _verifyPin() async {
    final isValid = await _pinService.verifyPin(_pin);
    if (isValid) {
      _navigateToHome();
    } else {
      setState(() {
        _pin = '';
        _errorMessage = 'Incorrect PIN. Please try again.';
      });
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const Spacer(flex: 2),

              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:  AppColors.gold.withOpacity(0.4),
                    width: 1.5,
                  ),
                  color: const Color(0xFF0E1628),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 32,
                  color: AppColors.gold,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEFF3FC),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Enter your PIN to continue',
                style: TextStyle(fontSize: 13, color: Color(0xFF7A8BAD)),
              ),

              const SizedBox(height: 40),

              // PIN dots
              _buildPinDots(),

              const SizedBox(height: 16),

              SizedBox(
                height: 20,
                child: _errorMessage != null
                    ? Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFF4D4D),
                        ),
                      )
                    : null,
              ),

              const Spacer(flex: 3),

              // Keypad
              _buildKeypad(),

              const SizedBox(height: 24),

              // Biometric button
              if (_biometricAvailable)
                GestureDetector(
                  onTap: _authenticateWithBiometrics,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF1E2D4A)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fingerprint_rounded,
                          color: AppColors.gold,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Use Biometrics',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < _pin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ?  AppColors.gold : const Color(0xFF1E2D4A),
            border: Border.all(
              color: filled
                  ?  AppColors.gold
                  : const Color(0xFF2E3D5A),
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            if (key.isEmpty) return const SizedBox(width: 72, height: 72);
            if (key == 'del') {
              return _KeyButton(
                onTap: _onDelete,
                child: const Icon(
                  Icons.backspace_outlined,
                  color: Color(0xFF7A8BAD),
                  size: 22,
                ),
              );
            }
            return _KeyButton(
              onTap: () => _onKeyTap(key),
              child: Text(
                key,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEFF3FC),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _KeyButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _KeyButton({required this.onTap, required this.child});

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 72,
          height: 72,
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0E1628),
            border: Border.all(color: const Color(0xFF1E2D4A)),
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}