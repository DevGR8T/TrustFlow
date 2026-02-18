import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trust_flow/core/utils/secure_screen_mixin.dart';
import 'package:trust_flow/features/onboarding/presentation/widgets/page_transitions.dart';
import 'package:trust_flow/features/onboarding/presentation/widgets/subtle_grid_background.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../domain/entities/document_type.dart';
import '../../domain/repositories/document_capture_repository.dart';
import '../../data/repositories/document_capture_repository_impl.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/progress_indicator_widget.dart';
import 'face_capture_screen.dart';
import 'consent_screen.dart' show _NavBackButton, _SubtleGridBackground, _fadeRoute;

class DocumentCaptureScreen extends StatefulWidget {
  const DocumentCaptureScreen({Key? key}) : super(key: key);

  @override
  State<DocumentCaptureScreen> createState() => _DocumentCaptureScreenState();
}

class _DocumentCaptureScreenState extends State<DocumentCaptureScreen>
    with SingleTickerProviderStateMixin,  WidgetsBindingObserver, SecureScreenMixin {
  late AnimationController _enterController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late DocumentCaptureRepository _documentRepo;

  DocumentType? _selectedType;
  String? _frontImagePath;
  String? _backImagePath;

  bool get _requiresBack => _selectedType?.requiresBackImage ?? false;

  bool get _canProceed =>
      _selectedType != null &&
      _frontImagePath != null &&
      (!_requiresBack || _backImagePath != null);

  @override
  void initState() {
    super.initState();
    _documentRepo = DocumentCaptureRepositoryImpl();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _enterController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic));
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  Future<void> _captureImage(bool isFront) async {
  try {
    print('🎯 Starting image capture...');
    
    final source = await _showImageSourceDialog();
    if (source == null) {
      print('❌ User cancelled source selection');
      return;
    }

    print('📷 Selected source: $source');
    
    final imagePath = await _documentRepo.captureDocument(source);

    print('📸 Captured image path: $imagePath');

    if (imagePath != null) {
      setState(() {
        if (isFront) {
          _frontImagePath = imagePath;
        } else {
          _backImagePath = imagePath;
        }
      });
      print('✅ Image saved successfully');
    } else {
      print('⚠️ No image path returned');
    }
  } catch (e) {
    print('💥 Error capturing image: $e');
    if (mounted) {
      ErrorDialog.show(
        context,
        title: 'Camera Error',
        message: 'Failed to capture image: $e',
        primaryActionLabel: 'OK',
      );
    }
  }
}

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primaryBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _ImageSourceOption(
                icon: Icons.camera_alt_outlined,
                label: 'Take Photo',
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const Divider(height: 1, color: AppColors.primaryBorder),
              _ImageSourceOption(
                icon: Icons.photo_library_outlined,
                label: 'Choose from Gallery',
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _retake(bool isFront) {
    setState(() {
      if (isFront) {
        _frontImagePath = null;
      } else {
        _backImagePath = null;
      }
    });
  }

  void _onContinue() {
    if (_frontImagePath == null) return;

    context.read<OnboardingBloc>().add(
          UploadDocumentEvent(
            documentType: _selectedType!.label,
            frontImagePath: _frontImagePath!,
            backImagePath: _requiresBack ? _backImagePath : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingLoading) {
          LoadingOverlay.show(context, message: 'Uploading document…');
        } else {
          LoadingOverlay.hide(context);
        }
        if (state is DocumentUploaded) {
          Navigator.push(context, fadeRoute(const FaceCaptureScreen()));
        } else if (state is OnboardingError) {
          ErrorDialog.show(
            context,
            title: 'Upload Failed',
            message: state.message,
            primaryActionLabel: 'Try Again',
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Stack(
          children: [
            const SubtleGridBackground(),
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
                              const OnboardingProgressBar(currentStep: 3),
                              const SizedBox(height: 32),
                              _buildHeader(),
                              const SizedBox(height: 28),
                              _buildDocTypeSelector(),
                              if (_selectedType != null) ...[
                                const SizedBox(height: 28),
                                _buildCaptureSection(),
                              ],
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
          const StepCounterBadge(currentStep: 3, totalSteps: 5),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.documentTitle,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.7,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 36,
          height: 3,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.gold, AppColors.goldLight]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          AppStrings.documentSubtitle,
          style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildDocTypeSelector() {
    final types = DocumentType.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELECT DOCUMENT TYPE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textDisabled,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.4,
          children: types
              .map((t) => _DocTypeChip(
                    type: t,
                    selected: _selectedType == t,
                    onTap: () => setState(() {
                      _selectedType = t;
                      _frontImagePath = null;
                      _backImagePath = null;
                    }),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCaptureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CAPTURE DOCUMENT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textDisabled,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        _CaptureCard(
          label: AppStrings.documentFront,
          imagePath: _frontImagePath,
          onCapture: () => _captureImage(true),
          onRetake: () => _retake(true),
        ),
        if (_requiresBack) ...[
          const SizedBox(height: 12),
          _CaptureCard(
            label: AppStrings.documentBack,
            imagePath: _backImagePath,
            onCapture: () => _captureImage(false),
            onRetake: () => _retake(false),
          ),
        ],
        const SizedBox(height: 16),
        _buildTips(),
      ],
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBorder, width: 1),
      ),
      child: Column(
        children: const [
          _TipRow(Icons.wb_sunny_outlined, 'Use good lighting — avoid shadows or glare'),
          SizedBox(height: 8),
          _TipRow(Icons.crop_free_rounded, 'Ensure all 4 corners of the document are visible'),
          SizedBox(height: 8),
          _TipRow(Icons.text_fields_rounded, 'Text must be sharp and legible'),
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
        label: AppStrings.documentConfirm,
        onPressed: _canProceed ? _onContinue : null,
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.gold.withOpacity(0.1),
        ),
        child: Icon(icon, color: AppColors.gold, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textDisabled,
      ),
    );
  }
}

class _DocTypeChip extends StatelessWidget {
  final DocumentType type;
  final bool selected;
  final VoidCallback onTap;

  const _DocTypeChip({required this.type, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold.withOpacity(0.08) : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.gold.withOpacity(0.5) : AppColors.primaryBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(type.icon,
                size: 16,
                color: selected ? AppColors.gold : AppColors.textDisabled),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                type.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.gold : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureCard extends StatelessWidget {
  final String label;
  final String? imagePath;
  final VoidCallback onCapture;
  final VoidCallback onRetake;

  const _CaptureCard({
    required this.label,
    required this.imagePath,
    required this.onCapture,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    final captured = imagePath != null;
    return GestureDetector(
      onTap: captured ? null : onCapture,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 150,
        decoration: BoxDecoration(
          color: captured ? AppColors.successDim : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: captured
                ? AppColors.success.withOpacity(0.4)
                : AppColors.primaryBorder,
            width: captured ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            if (captured)
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.file(
                  File(imagePath!),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            if (!captured)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CustomPaint(painter: _DashedBorderPainter()),
                ),
              ),
            if (captured)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!captured) ...[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.gold,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tap to capture $label',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$label captured',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onRetake,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          'Retake',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TipRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textDisabled),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textMuted, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0, dashGap = 5.0;
    final paint = Paint()
      ..color = AppColors.primaryBorder
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
        const Radius.circular(14),
      ));
    _drawDashedPath(canvas, path, paint, dashWidth, dashGap);
  }

  void _drawDashedPath(Canvas c, Path p, Paint paint, double dw, double dg) {
    for (final metric in p.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final end = (dist + dw).clamp(0.0, metric.length);
        c.drawPath(metric.extractPath(dist, end), paint);
        dist += dw + dg;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}