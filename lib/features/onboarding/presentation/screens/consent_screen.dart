import 'package:flutter/material.dart';
import 'package:trust_flow/features/onboarding/presentation/widgets/page_transitions.dart';
import 'package:trust_flow/features/onboarding/presentation/widgets/subtle_grid_background.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../widgets/custom_button.dart';
import '../widgets/progress_indicator_widget.dart';
import 'personal_info_screen.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({Key? key}) : super(key: key);

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<_ConsentItem> _items = [
    _ConsentItem(
      icon: Icons.person_outline_rounded,
      title: 'Personal Information',
      description: 'Full name, date of birth, phone number, and email address for identity matching.',
      required: true,
    ),
    _ConsentItem(
      icon: Icons.badge_outlined,
      title: 'Government ID',
      description: 'Images of your NIN, passport, driver\'s licence, or voter\'s card.',
      required: true,
    ),
    _ConsentItem(
      icon: Icons.face_retouching_natural,
      title: 'Biometric Data',
      description: 'A live selfie photograph for facial comparison against your submitted ID.',
      required: true,
    ),
    _ConsentItem(
      icon: Icons.account_balance_outlined,
      title: 'BVN Verification',
      description: 'Your BVN is verified against NIBSS records to confirm identity.',
      required: true,
    ),
    _ConsentItem(
      icon: Icons.notifications_none_rounded,
      title: 'Communication',
      description: 'Updates on your verification status via email and SMS notifications.',
      required: false,
    ),
  ];

  bool get _canProceed => _items.where((i) => i.required).every((i) => i.accepted);

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _enterController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic));
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
         SubtleGridBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            const OnboardingProgressBar(currentStep: 0),
                            const SizedBox(height: 32),
                            _buildHeader(),
                            const SizedBox(height: 28),
                            _buildConsentCards(),
                            const SizedBox(height: 32),
                            _buildLegalNote(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomBar(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          _NavBackButton(onTap: () => Navigator.pop(context)),
          const Spacer(),
          const StepCounterBadge(currentStep: 0, totalSteps: 5),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.consentTitle,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.7,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Container(width: 36, height: 3,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.gold, AppColors.goldLight]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          AppStrings.consentSubtitle,
          style: TextStyle(
            fontSize: 14, color: AppColors.textMuted, height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildConsentCards() {
    return Column(
      children: _items.asMap().entries.map((e) {
        final item = e.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ConsentCard(
            item: item,
            onToggle: (val) => setState(() => item.accepted = val),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegalNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoDim,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.info),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Your data is processed in compliance with the Nigeria Data Protection Regulation (NDPR) and CBN KYC guidelines. We will never sell or share your data with third parties.',
              style: TextStyle(
                fontSize: 12, color: AppColors.info, height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: BoxDecoration(
        color: AppColors.primary,
        border: Border(top: BorderSide(color: AppColors.primaryBorder, width: 1)),
      ),
      child: Column(
        children: [
          PrimaryButton(
            label: AppStrings.consentAgree,
            onPressed: _canProceed
                ? () => Navigator.push(context,
                    fadeRoute(const PersonalInfoScreen()))
                : null,
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: AppStrings.consentDecline,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _ConsentCard extends StatelessWidget {
  final _ConsentItem item;
  final ValueChanged<bool> onToggle;

  const _ConsentCard({required this.item, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!item.accepted),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.accepted
              ? AppColors.gold.withOpacity(0.06)
              : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.accepted
                ? AppColors.gold.withOpacity(0.35)
                : AppColors.primaryBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.accepted
                    ? AppColors.gold.withOpacity(0.12)
                    : AppColors.primaryMid,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.icon,
                size: 18,
                color: item.accepted ? AppColors.gold : AppColors.textDisabled,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (item.required) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.errorDim,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'REQUIRED',
                            style: TextStyle(
                              fontSize: 8, fontWeight: FontWeight.w700,
                              color: AppColors.error, letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 11.5, color: AppColors.textMuted, height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.accepted ? AppColors.gold : Colors.transparent,
                border: Border.all(
                  color: item.accepted
                      ? AppColors.gold
                      : AppColors.primaryBorder,
                  width: 1.5,
                ),
              ),
              child: item.accepted
                  ? const Icon(Icons.check_rounded,
                      size: 13, color: AppColors.primary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentItem {
  final IconData icon;
  final String title;
  final String description;
  final bool required;
  bool accepted;

  _ConsentItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.required,
    bool? accepted,
  }) : accepted = accepted ?? false;
}

// ── Shared helper widgets used across all screens ──────────────

class _NavBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NavBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryBorder, width: 1),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}



