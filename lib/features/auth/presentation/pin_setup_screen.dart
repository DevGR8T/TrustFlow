import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trust_flow/core/di/injection_container.dart';
import 'package:trust_flow/core/security/pin_service.dart';
import 'pin_entry_screen.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({Key? key}) : super(key: key);

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final PinService _pinService = sl<PinService>();

  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _errorMessage;

  void _onKeyTap(String value) {
    HapticFeedback.lightImpact();
    setState(() {
      _errorMessage = null;
      if (_isConfirming) {
        if (_confirmPin.length < 4) {
          _confirmPin += value;
          if (_confirmPin.length == 4) _validatePins();
        }
      } else {
        if (_pin.length < 4) {
          _pin += value;
          if (_pin.length == 4) {
            Future.delayed(const Duration(milliseconds: 200), () {
              setState(() => _isConfirming = true);
            });
          }
        }
      }
    });
  }

  void _onDelete() {
    HapticFeedback.lightImpact();
    setState(() {
      _errorMessage = null;
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  Future<void> _validatePins() async {
    if (_pin == _confirmPin) {
      await _pinService.savePin(_pin);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PinEntryScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'PINs do not match. Try again.';
        _confirmPin = '';
        _pin = '';
        _isConfirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPin = _isConfirming ? _confirmPin : _pin;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Lock icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.4),
                    width: 1.5,
                  ),
                  color: const Color(0xFF0E1628),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 32,
                  color: Color(0xFFD4AF37),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                _isConfirming ? 'Confirm your PIN' : 'Create a PIN',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEFF3FC),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _isConfirming
                    ? 'Enter your PIN again to confirm'
                    : 'This PIN secures access to TrustFlow',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7A8BAD),
                ),
              ),

              const SizedBox(height: 40),

              // PIN dots
              _buildPinDots(currentPin),

              const SizedBox(height: 16),

              // Error message
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

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots(String currentPin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < currentPin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? const Color(0xFFD4AF37)
                : const Color(0xFF1E2D4A),
            border: Border.all(
              color: filled
                  ? const Color(0xFFD4AF37)
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

class _KeyButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _KeyButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0E1628),
          border: Border.all(color: const Color(0xFF1E2D4A)),
        ),
        child: Center(child: child),
      ),
    );
  }
}