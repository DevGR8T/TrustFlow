import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trust_flow/core/utils/secure_screen_mixin.dart';
import 'package:trust_flow/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:trust_flow/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:trust_flow/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:trust_flow/features/onboarding/presentation/widgets/page_transitions.dart';
import 'package:trust_flow/features/onboarding/presentation/widgets/subtle_grid_background.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/utils/phone_validator.dart';
import '../../../../core/utils/phone_input_formatter.dart';
import '../widgets/custom_button.dart';
import '../widgets/progress_indicator_widget.dart' ;
import 'bvn_input_screen.dart';


class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen>
    with SingleTickerProviderStateMixin,  WidgetsBindingObserver, SecureScreenMixin {
  late AnimationController _enterController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final _formKey        = GlobalKey<FormState>();
  final _firstNameCtrl  = TextEditingController();
  final _lastNameCtrl   = TextEditingController();
  final _dobCtrl        = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _emailCtrl      = TextEditingController();

  bool _formDirty = false;
  String? _networkName;

  bool get _canProceed =>
      _firstNameCtrl.text.isNotEmpty &&
      _lastNameCtrl.text.isNotEmpty &&
      _dobCtrl.text.isNotEmpty &&
      _phoneCtrl.text.isNotEmpty &&
      _emailCtrl.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim  = CurvedAnimation(parent: _enterController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic));
    _enterController.forward();

    for (final ctrl in [_firstNameCtrl, _lastNameCtrl, _dobCtrl, _phoneCtrl, _emailCtrl]) {
      ctrl.addListener(() {
        if (_formDirty) setState(() {});
      });
    }
    
    // Listen for network name changes
    _phoneCtrl.addListener(_updateNetwork);
  }

  void _updateNetwork() {
    final network = NigerianPhoneValidator.getNetwork(_phoneCtrl.text);
    if (network != _networkName) {
      setState(() => _networkName = network);
    }
  }

  @override
  void dispose() {
    _enterController.dispose();
    _phoneCtrl.removeListener(_updateNetwork);
    for (final ctrl in [_firstNameCtrl, _lastNameCtrl, _dobCtrl, _phoneCtrl, _emailCtrl]) {
      ctrl.dispose();
    }
     // Remove observer before super.dispose()
  WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now  = DateTime.now();
    final min  = DateTime(now.year - 100);
    final max  = DateTime(now.year - 18);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: min,
      lastDate: max,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.gold,
            surface: AppColors.primaryMid,
            onSurface: AppColors.textPrimary,
          ),
          dialogBackgroundColor: AppColors.primaryMid,
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

void _onContinue() {
  setState(() => _formDirty = true);
  if (_formKey.currentState!.validate()) {
    context.read<OnboardingBloc>().add(SavePersonalInfoEvent(
      fullName: '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}',
      dateOfBirth: _dobCtrl.text,
      phoneNumber: _phoneCtrl.text,
      email: _emailCtrl.text,
    ));
    // navigation now handled by BlocListener
  }
}

  @override
  Widget build(BuildContext context) {
     return BlocListener<OnboardingBloc, OnboardingState>(
    listener: (context, state) {
      if (state is PersonalInfoSaved) {
        Navigator.push(context, fadeRoute(const BvnInputScreen()));
      }
    },
    child:  Scaffold(
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
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              const OnboardingProgressBar(currentStep: 1),
                              const SizedBox(height: 32),
                              _buildHeader(),
                              const SizedBox(height: 28),
                              _buildFields(),
                              const SizedBox(height: 32),
                            ],
                          ),
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
    ));
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          NavBackButton(onTap: () => Navigator.pop(context)),
          const Spacer(),
          const StepCounterBadge(currentStep: 1, totalSteps: 5),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.personalInfoTitle,
          style: TextStyle(
            fontSize: 30, fontWeight: FontWeight.w800,
            color: AppColors.textPrimary, letterSpacing: -0.7, height: 1.15,
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
          AppStrings.personalInfoSubtitle,
          style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildFields() {
    return Column(
      children: [
        // Name row
        Row(
          children: [
            Expanded(
              child: _AppTextField(
                controller: _firstNameCtrl,
                label: AppStrings.firstNameLabel,
                hint: 'Great',
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Required'
                    : v.trim().length < 2
                        ? 'Too short'
                        : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AppTextField(
                controller: _lastNameCtrl,
                label: AppStrings.lastNameLabel,
                hint: 'Enyinnaya',
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Required'
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // DOB
        _AppTextField(
          controller: _dobCtrl,
          label: AppStrings.dobLabel,
          hint: 'DD/MM/YYYY',
          readOnly: true,
          onTap: _pickDate,
          suffixIcon: Icons.calendar_today_outlined,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 14),

        // Phone with Nigerian validation
        _AppTextField(
          controller: _phoneCtrl,
          label: AppStrings.phoneLabel,
          hint: '0801 234 5678',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            NigerianPhoneInputFormatter(),
            LengthLimitingTextInputFormatter(14), // 11 digits + 2 spaces
          ],
          prefixIcon: Icons.phone_outlined,
          validator: (v) => NigerianPhoneValidator.validate(v),
          suffixWidget: _networkName != null
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _networkName!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 14),

        // Email
        _AppTextField(
          controller: _emailCtrl,
          label: AppStrings.emailLabel,
          hint: 'chidi@example.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline_rounded,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v)) {
              return 'Enter a valid email address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: BoxDecoration(
        color: AppColors.primary,
        border: Border(
          top: BorderSide(color: AppColors.primaryBorder, width: 1),
        ),
      ),
      child: PrimaryButton(
        label: AppStrings.continueButton,
        onPressed: _onContinue,
      ),
    );
  }
}

// ── Reusable app-wide text field ─────────────────────────────────
class _AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool readOnly;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? suffixWidget;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final int? maxLength;

  const _AppTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.readOnly = false,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixWidget,
    this.onTap,
    this.validator,
    this.maxLength,
  });

  @override
  State<_AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<_AppTextField> {
  bool _obscured = true;
  bool _focused  = false;
  late FocusNode _focusNode;

  bool get isPassword => widget.obscureText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Floating label
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: _focused ? AppColors.gold : AppColors.textDisabled,
            letterSpacing: 0.5,
          ),
          child: Text(widget.label.toUpperCase()),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          readOnly: widget.readOnly,
          obscureText: isPassword && _obscured,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          onTap: widget.onTap,
          validator: widget.validator,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            counterText: '',
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 18)
                : null,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : widget.suffixIcon != null
                    ? Icon(widget.suffixIcon, size: 18)
                    : null,
            suffix: widget.suffixWidget,
          ),
        ),
      ],
    );
  }
}