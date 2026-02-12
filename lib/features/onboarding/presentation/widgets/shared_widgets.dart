import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class NavBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark; // NEW: for dark backgrounds

  const NavBackButton({
    Key? key,
    required this.onTap,
    this.isDark = false, // NEW
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.black.withOpacity(0.5) 
              : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark 
                ? Colors.white.withOpacity(0.3) 
                : AppColors.primaryBorder,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: isDark ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}

