import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trust_flow/core/utils/secure_screen_mixin.dart';
import 'package:trust_flow/features/onboarding/presentation/widgets/page_transitions.dart';
import 'package:trust_flow/features/onboarding/presentation/widgets/subtle_grid_background.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/utils/bvn_validator.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/progress_indicator_widget.dart';
import 'document_capture_screen.dart';


class BvnInputScreen extends StatefulWidget {
  const BvnInputScreen({super.key});

  @override
  State<BvnInputScreen> createState() => _BvnInputScreenState();
}

class _BvnInputScreenState extends State<BvnInputScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, SecureScreenMixin {
  late AnimationController _enterController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final _bvnController = TextEditingController();
  final _focusNode     = FocusNode();
  bool _hasInteracted  = false;
  String? _validationError;

  bool get _isValidLength => _bvnController.text.length == AppConstants.bvnLength;
  
  bool get _isValid => 
      _isValidLength && 
      _validationError == null &&
      NigerianBvnValidator.validate(_bvnController.text) == null;

  String? get _bvnError {
    if (!_hasInteracted && _validationError == null) return null;
    
    if (_bvnController.text.isEmpty) {
      return 'Please enter your BVN';
    }
    
    // Show real-time validation error if user has typed something
    if (_validationError != null && _hasInteracted) {
      return _validationError;
    }
    
    if (_bvnController.text.length < AppConstants.bvnLength) {
      return 'BVN must be exactly 11 digits';
    }
    
    return _validationError;
  }

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    );
    _fadeAnim  = CurvedAnimation(parent: _enterController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic));
    _enterController.forward();
    _bvnController.addListener(_validateBvn);
  }

  void _validateBvn() {
    setState(() {
      if (_bvnController.text.length == AppConstants.bvnLength) {
        _validationError = NigerianBvnValidator.validate(_bvnController.text);
      } else {
        _validationError = null;
      }
    });
  }

  @override
  void dispose() {
    _enterController.dispose();
    _bvnController.removeListener(_validateBvn);
    _bvnController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onVerify() {
    setState(() => _hasInteracted = true);
    
    final error = NigerianBvnValidator.validate(_bvnController.text);
    if (error != null) {
      setState(() => _validationError = error);
      return;
    }
    
    if (_isValid) {
      context.read<OnboardingBloc>().add(
        VerifyBvnEvent(bvn: _bvnController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingLoading) {
          LoadingOverlay.show(context, message: 'Verifying BVN with NIBSS…');
        } else {
          LoadingOverlay.hide(context);
        }
        if (state is BvnVerified) {
          Navigator.push(context, fadeRoute(const DocumentCaptureScreen()));
        } else if (state is OnboardingError) {
          ErrorDialog.show(
            context,
            title: 'Verification Failed',
            message: state.message,
            primaryActionLabel: 'Try Again',
            onPrimaryAction: () => Navigator.pop(context),
          );
        }
      },
      child: Scaffold(
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
                              const OnboardingProgressBar(currentStep: 2),
                              const SizedBox(height: 32),
                              _buildHeader(),
                              const SizedBox(height: 36),
                              _buildBvnField(),
                              const SizedBox(height: 20),
                              _buildSecurityBadge(),
                              const SizedBox(height: 20),
                              _buildWhatIsBvn(context),
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
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          NavBackButton(onTap: () => Navigator.pop(context)),
          const Spacer(),
          const StepCounterBadge(currentStep: 2, totalSteps: 5),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.bvnTitle,
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
          AppStrings.bvnSubtitle,
          style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildBvnField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BANK VERIFICATION NUMBER',
          style: TextStyle(
            fontSize: 11.5, 
            fontWeight: FontWeight.w600,
            color: AppColors.textDisabled, 
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        
        // BVN input field
        TextFormField(
          controller: _bvnController,
          focusNode: _focusNode,
          keyboardType: TextInputType.number,
          maxLength: AppConstants.bvnLength,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 2,
          ),
          decoration: InputDecoration(
            hintText: '00000000000',
            hintStyle: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textDisabled.withOpacity(0.3),
              letterSpacing: 2,
            ),
            counterText: '',
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: _bvnError != null 
                    ? AppColors.error 
                    : _isValid
                        ? AppColors.success
                        : AppColors.primaryBorder,
                width: 1.5,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: _bvnError != null 
                    ? AppColors.error
                    : _isValid
                        ? AppColors.success 
                        : AppColors.gold,
                width: 2,
              ),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            // Show checkmark when valid
            suffixIcon: _isValid
                ? const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 24,
                  )
                : null,
          ),
        ),

        // Error message
        if (_bvnError != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 13, color: AppColors.error),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  _bvnError!,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.error),
                ),
              ),
            ],
          ),
        ],

        // Success message
        if (_isValid && _bvnError == null) ...[
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.check_circle_outline_rounded,
                  size: 13, color: AppColors.success),
              SizedBox(width: 5),
              Text('Valid BVN number',
                  style: TextStyle(fontSize: 11.5, color: AppColors.success)),
            ],
          ),
        ],

        // Character counter for user feedback
        if (_bvnController.text.isNotEmpty && 
            _bvnController.text.length < AppConstants.bvnLength) ...[
          const SizedBox(height: 8),
          Text(
            '${_bvnController.text.length}/${AppConstants.bvnLength} digits',
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ],
    );
  }
 
  Widget _buildSecurityBadge() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.successDim,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withOpacity(0.2), width: 1,
        ),
      ),
      child: Row(
        children: const [
          Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.success),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your BVN is encrypted and verified directly with NIBSS. It is never stored on our servers.',
              style: TextStyle(fontSize: 12, color: AppColors.success, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatIsBvn(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ErrorDialog.show(
          context,
          title: 'What is a BVN?',
          message:
              'A Bank Verification Number (BVN) is an 11-digit unique identifier issued by the Central Bank of Nigeria (CBN) to every bank account holder. You can find your BVN by dialling *565*0# on your registered phone number.',
          primaryActionLabel: 'Got it',
          type: ErrorDialogType.info,
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.help_outline_rounded,
              size: 14, color: AppColors.gold),
          SizedBox(width: 6),
          Text(
            AppStrings.bvnWhatsThis,
            style: TextStyle(
              fontSize: 13, color: AppColors.gold,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.gold,
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
        border: Border(
          top: BorderSide(color: AppColors.primaryBorder, width: 1),
        ),
      ),
      child: PrimaryButton(
        label: AppStrings.bvnVerify,
        onPressed: _isValid ? _onVerify : null,
      ),
    );
  }
}