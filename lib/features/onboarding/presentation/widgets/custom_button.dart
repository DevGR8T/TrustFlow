import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';

/// Gold gradient primary button — the main CTA across all screens
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? trailingIcon;
  final double height;

  const PrimaryButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.trailingIcon = Icons.arrow_forward_rounded,
    this.height = 56,
  }) : super(key: key);

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onPressed != null && !widget.isLoading) {
      _pressController.forward();
    }
  }

  void _onTapUp(_) => _pressController.reverse();
  void _onTapCancel() => _pressController.reverse();

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              widget.onPressed!();
            }
          : null,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: enabled
                  ? const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFF0D060)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: enabled ? null : AppColors.primaryBorder,
              borderRadius: BorderRadius.circular(8),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (widget.trailingIcon != null) ...[
                          const SizedBox(width: 10),
                          Icon(
                            widget.trailingIcon,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ghost / outlined button for secondary actions
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final Color? borderColor;
  final Color? textColor;
  final double height;
  final bool isDark; // NEW: for dark backgrounds

  const SecondaryButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.borderColor,
    this.textColor,
    this.height = 52,
    this.isDark = false, // NEW
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Auto-detect colors based on dark mode
    final effectiveBorderColor = borderColor ?? 
        (isDark ? Colors.white.withOpacity(0.3) : AppColors.primaryBorder);
    final effectiveTextColor = textColor ?? 
        (isDark ? Colors.white : AppColors.textMuted);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveTextColor,
          backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent,
          side: BorderSide(color: effectiveBorderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 16, color: effectiveTextColor),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: effectiveTextColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Destructive / danger text button
class DangerTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const DangerTextButton({
    Key? key,
    required this.label,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.error,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}