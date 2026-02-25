import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/exchange_rate_bloc.dart';
import '../bloc/exchange_rate_state.dart';

class ExchangeRateBanner extends StatefulWidget {
  const ExchangeRateBanner({Key? key}) : super(key: key);

  @override
  State<ExchangeRateBanner> createState() => _ExchangeRateBannerState();
}

class _ExchangeRateBannerState extends State<ExchangeRateBanner>
    with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;
  late AnimationController _valueController;
  late Animation<double> _valueFade;
  late Animation<Offset> _valueSlide;
  double? _lastRate;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _blinkAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _valueController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _valueFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _valueController, curve: Curves.easeOut),
    );

    _valueSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _valueController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _animateNewValue(double rate) {
    if (_lastRate != rate) {
      _lastRate = rate;
      _valueController.forward(from: 0);
    }
  }

  String _formatLastUpdated(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExchangeRateBloc, ExchangeRateState>(
      builder: (context, state) {
        if (state is ExchangeRateLoaded) {
          _animateNewValue(state.rate.usdToNgn);
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1628),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1E2D4A)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // ← no Flexible/Expanded here
            children: [
              // Blinking live dot
              AnimatedBuilder(
                animation: _blinkAnimation,
                builder: (_, __) => Opacity(
                  opacity: state is ExchangeRateLoaded
                      ? _blinkAnimation.value
                      : 0.3,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: state is ExchangeRateError
                          ? const Color(0xFFFF4D4D)
                          : const Color(0xFF00D68F),
                      shape: BoxShape.circle,
                      boxShadow: state is ExchangeRateLoaded
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00D68F).withOpacity(0.6),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              const Text(
                'USD/NGN',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF7A8BAD),
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(width: 8),

              _buildValue(state), // ← no Flexible wrapper
            ],
          ),
        );
      },
    );
  }

  Widget _buildValue(ExchangeRateState state) {
    if (state is ExchangeRateLoading) {
      return const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: Color(0xFFD4AF37),
        ),
      );
    }

    if (state is ExchangeRateLoaded) {
      return Row(
        mainAxisSize: MainAxisSize.min, // ← no Flexible here either
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FadeTransition(
            opacity: _valueFade,
            child: SlideTransition(
              position: _valueSlide,
              child: Text(
                '₦${state.rate.usdToNgn.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD4AF37),
                  letterSpacing: 0.3,
                  fontFamily: "serif"
                ),
              ),
            ),
          ),
          const SizedBox(width: 3),
          Text(
            _formatLastUpdated(state.rate.lastUpdated),
            style: const TextStyle(
              fontSize: 8,
              color: Color(0xFF4A5A7A),
            ),
          ),
        ],
      );
    }

    if (state is ExchangeRateError) {
      return const Text(
        'Unavailable',
        style: TextStyle(fontSize: 11, color: Color(0xFF4A5A7A)),
      );
    }

    return const SizedBox.shrink();
  }
}