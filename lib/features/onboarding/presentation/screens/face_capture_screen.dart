import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trust_flow/features/onboarding/domain/repositories/liveness_detector_repository_impl.dart';
import 'package:trust_flow/features/onboarding/presentation/widgets/page_transitions.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../domain/entities/liveness_step.dart';
import '../../data/repositories/liveness_detector_repository_impl.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/progress_indicator_widget.dart';
import 'verification_status_screen.dart';

class FaceCaptureScreen extends StatefulWidget {
  const FaceCaptureScreen({Key? key}) : super(key: key);

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
      minFaceSize: 0.15,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  late LivenessDetectorRepository _livenessRepo;

  bool _isDetecting = false;
  bool _isCameraInitialized = false;
  String? _capturedImagePath;
  bool _permissionDenied = false;
  bool _hasCaptured = false;

  LivenessStep _currentStep = LivenessStep.initial;
  bool _faceDetected = false;
  int _consecutiveFrames = 0;

  // Liveness results
  bool _blinkDetected = false;
  bool _smileDetected = false;
  bool _leftTurnDetected = false;
  bool _rightTurnDetected = false;

  // Frame confirmation counters
  int _rightTurnFrames = 0;
  int _leftTurnFrames = 0;
  int _smileFrames = 0;
  static const int _confirmFrames = 5;

  // Blink state tracker
  int _blinkState = 0;

  String _instructionText = 'Position your face in the frame';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissionsAndInitialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  print('📱 App lifecycle state: $state');
  
  final controller = _cameraController;
  
  if (state == AppLifecycleState.inactive) {
    print('⏸️ App going inactive');
    controller?.stopImageStream();
  } else if (state == AppLifecycleState.paused) {
    print('⏸️ App paused');
    controller?.dispose();
    setState(() {
      _cameraController = null;
      _isCameraInitialized = false;
    });
  } else if (state == AppLifecycleState.resumed) {
    print('▶️ App resumed');
    // Check permission and reinitialize
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _requestPermissionsAndInitialize();
      }
    });
  }
}

 Future<void> _requestPermissionsAndInitialize() async {
  if (_isCameraInitialized && _cameraController != null) {
    return;
  }
  
  final status = await Permission.camera.status;
  
  if (status.isGranted) {
    await _initializeCamera();
    return;
  }
  
  if (status.isPermanentlyDenied) {
    setState(() => _permissionDenied = true);
    return;
  }
  
  final result = await Permission.camera.request();
  
  if (result.isGranted) {
    await _initializeCamera();
  } else {
    setState(() => _permissionDenied = true);
  }
}

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception('No cameras available');

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      // Initialize repository
      _livenessRepo = LivenessDetectorRepositoryImpl();

      setState(() => _isCameraInitialized = true);
      _cameraController!.startImageStream(_processCameraImage);
     
    } catch (e) {
      
      if (mounted) {
        ErrorDialog.show(
          context,
          title: 'Camera Error',
          message: 'Failed to initialize camera: ${e.toString()}',
          primaryActionLabel: 'OK',
        );
      }
    }
  }

  Future<void> _processCameraImage(CameraImage cameraImage) async {
    if (_isDetecting || _hasCaptured) return;
    _isDetecting = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in cameraImage.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(
        cameraImage.width.toDouble(),
        cameraImage.height.toDouble(),
      );

      final camera = _cameraController!.description;
      final rotation = InputImageRotationValue.fromRawValue(
            camera.sensorOrientation,
          ) ??
          InputImageRotation.rotation0deg;

      final inputImageFormat = InputImageFormatValue.fromRawValue(
            cameraImage.format.raw,
          ) ??
          InputImageFormat.yuv420;

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: rotation,
          format: inputImageFormat,
          bytesPerRow: cameraImage.planes.first.bytesPerRow,
        ),
      );

      final faces = await _faceDetector.processImage(inputImage);

      if (mounted) {
        _processLivenessDetection(faces, imageSize);
      }
    } catch (e) {
      
    } finally {
      _isDetecting = false;
    }
  }

  void _processLivenessDetection(List<Face> faces, Size imageSize) {
    if (_hasCaptured) return;

    if (faces.isEmpty || faces.length > 1) {
      setState(() {
        _faceDetected = false;
        _consecutiveFrames = 0;
        _instructionText = faces.isEmpty
            ? 'Position your face in the frame'
            : 'Multiple faces detected. Ensure only you are visible';
      });
      return;
    }

    final face = faces.first;

    if (!_isFaceValid(face, imageSize)) {
      setState(() {
        _faceDetected = false;
        _consecutiveFrames = 0;
      });
      return;
    }

    // Valid face
    if (!_faceDetected) setState(() => _faceDetected = true);
    _consecutiveFrames++;


    switch (_currentStep) {
      case LivenessStep.initial:
        _processInitialStep();
        break;
      case LivenessStep.blinkDetection:
        _processBlinkDetection(face);
        break;
      case LivenessStep.smileDetection:
        _processSmileDetection(face);
        break;
      case LivenessStep.turnLeft:
        _processTurnLeft(face);
        break;
      case LivenessStep.turnRight:
        _processTurnRight(face);
        break;
      case LivenessStep.completed:
        if (!_hasCaptured) {
          _hasCaptured = true;
          _captureVerificationPhoto();
        }
        break;
    }
  }

  bool _isFaceValid(Face face, Size imageSize) {
    final isValid = _livenessRepo.isFaceValid(face, imageSize);
    if (!isValid) {
      setState(() => _instructionText = _livenessRepo.getFaceValidationMessage());
    }
    return isValid;
  }

  void _processInitialStep() {
    if (_consecutiveFrames >= 5) {
      setState(() {
        _currentStep = LivenessStep.blinkDetection;
        _instructionText = 'Blink your eyes';
        _progress = 0.2;
      });
     
    } else {
      setState(() => _instructionText = 'Hold still... $_consecutiveFrames/5');
    }
  }

  void _processBlinkDetection(Face face) {
    final left = face.leftEyeOpenProbability;
    final right = face.rightEyeOpenProbability;
    if (left == null || right == null) return;

    final newState = _livenessRepo.updateBlinkState(left, right, _blinkState);

    if (newState == 3) {
      setState(() {
        _blinkDetected = true;
        _currentStep = LivenessStep.smileDetection;
        _instructionText = 'Now smile naturally';
        _progress = 0.4;
        _blinkState = 0;
      });
     
    } else {
      _blinkState = newState;
    }
  }

  void _processSmileDetection(Face face) {
    final smile = face.smilingProbability;
    if (smile == null) return;

   

    if (_livenessRepo.isSmileDetected(smile, _smileFrames, _confirmFrames)) {
      setState(() {
        _smileDetected = true;
        _currentStep = LivenessStep.turnLeft;
        _instructionText = 'Turn your head left';
        _progress = 0.6;
        _smileFrames = 0;
      });
      
    } else if (smile > 0.70) {
      _smileFrames++;
    } else {
      _smileFrames = 0;
    }
  }

  void _processTurnLeft(Face face) {
    final headY = face.headEulerAngleY;
   

    if (_livenessRepo.isLeftTurnDetected(headY, _leftTurnFrames, _confirmFrames)) {
      setState(() {
        _leftTurnDetected = true;
        _currentStep = LivenessStep.turnRight;
        _instructionText = 'Now turn your head right';
        _progress = 0.8;
        _leftTurnFrames = 0;
      });
     
    } else if (headY != null && headY > 12) {
      _leftTurnFrames++;
    } else {
      _leftTurnFrames = 0;
    }
  }

  void _processTurnRight(Face face) {
    final headY = face.headEulerAngleY;
    

    if (_livenessRepo.isRightTurnDetected(headY, _rightTurnFrames, _confirmFrames)) {
     
      setState(() {
        _rightTurnDetected = true;
        _currentStep = LivenessStep.completed;
        _instructionText = 'Capturing...';
        _progress = 1.0;
        _rightTurnFrames = 0;
      });
    } else if (headY != null && headY < -12) {
      _rightTurnFrames++;
     
    } else {
      _rightTurnFrames = 0;
    }
  }

  Future<void> _captureVerificationPhoto() async {
    if (_cameraController == null) return;

    try {
      final imagePath = await _livenessRepo.capturePhoto(_cameraController!);
      if (mounted) {
        setState(() => _capturedImagePath = imagePath);
      }
    } catch (e) {
     
      _hasCaptured = false;
      if (mounted) {
        ErrorDialog.show(
          context,
          title: 'Capture Error',
          message: 'Failed to capture photo. Please try again.',
          primaryActionLabel: 'Retry',
          onPrimaryAction: () => _resetLivenessDetection(),
        );
      }
    }
  }

  void _resetLivenessDetection() {
    setState(() {
      _hasCaptured = false;
      _currentStep = LivenessStep.initial;
      _blinkDetected = false;
      _smileDetected = false;
      _leftTurnDetected = false;
      _rightTurnDetected = false;
      _consecutiveFrames = 0;
      _blinkState = 0;
      _progress = 0.0;
      _instructionText = 'Position your face in the frame';
      _rightTurnFrames = 0;
      _leftTurnFrames = 0;
      _smileFrames = 0;
      _faceDetected = false;
    });
    _cameraController?.startImageStream(_processCameraImage);
  }

  void _retake() {
    setState(() => _capturedImagePath = null);
    _resetLivenessDetection();
  }

  void _onConfirm() {
    if (_capturedImagePath == null) {
      
      return;
    }



    final livenessData = {
      'blink_detected': _blinkDetected,
      'smile_detected': _smileDetected,
      'head_turn_left': _leftTurnDetected,
      'head_turn_right': _rightTurnDetected,
      'timestamp': DateTime.now().toIso8601String(),
    };


    context.read<OnboardingBloc>().add(
          UploadFaceCaptureEvent(
            imagePath: _capturedImagePath!,
            livenessVerified: true,
            livenessData: livenessData,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingLoading) {
          LoadingOverlay.show(context, message: 'Verifying facial biometrics…');
        } else {
          LoadingOverlay.hide(context);
        }
        if (state is FaceCaptureUploaded) {
          Navigator.push(context, fadeRoute(const VerificationStatusScreen()));
        } else if (state is OnboardingError) {
          ErrorDialog.show(
            context,
            title: 'Verification Failed',
            message: state.message,
            primaryActionLabel: 'Try Again',
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _capturedImagePath != null
            ? _buildPreviewScreen()
            : _permissionDenied
                ? _buildPermissionDenied()
                : _buildCameraScreen(),
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined, size: 80, color: AppColors.gold),
            const SizedBox(height: 24),
            const Text(
              'Camera Permission Required',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Please grant camera permission to complete facial verification.',
              style: TextStyle(fontSize: 14, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
                label: 'Open Settings', onPressed: () => openAppSettings()),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraScreen() {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.gold));
    }

    final size = MediaQuery.of(context).size;
    final cameraAspectRatio = _cameraController!.value.aspectRatio;

    return Stack(
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.width,
              height: size.width * cameraAspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          ),
        ),
        CustomPaint(
          size: Size.infinite,
          painter: _FaceOvalPainter(
              faceDetected: _faceDetected, currentStep: _currentStep),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: [
                NavBackButton(
                    onTap: () => Navigator.pop(context), isDark: true),
                const Spacer(),
                const StepCounterBadge(currentStep: 4, totalSteps: 5),
              ],
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 70,
          left: 24,
          right: 24,
          child: Column(
            children: [
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.gold),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 12),
              _buildLivenessChecklist(),
            ],
          ),
        ),
        Positioned(
          bottom: 100,
          left: 24,
          right: 24,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: _currentStep == LivenessStep.completed
                  ? AppColors.success.withOpacity(0.95)
                  : Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _currentStep == LivenessStep.completed
                    ? AppColors.success
                    : AppColors.gold.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(_getInstructionIcon(), color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _instructionText,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getInstructionIcon() {
    switch (_currentStep) {
      case LivenessStep.initial:
        return Icons.face;
      case LivenessStep.blinkDetection:
        return Icons.remove_red_eye;
      case LivenessStep.smileDetection:
        return Icons.sentiment_satisfied;
      case LivenessStep.turnLeft:
        return Icons.turn_left;
      case LivenessStep.turnRight:
        return Icons.turn_right;
      case LivenessStep.completed:
        return Icons.check_circle;
    }
  }

  Widget _buildLivenessChecklist() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _LivenessCheckItem(
            icon: Icons.face,
            label: 'Position',
            completed: _currentStep.index > LivenessStep.initial.index,
          ),
          _LivenessCheckItem(
              icon: Icons.remove_red_eye,
              label: 'Blink',
              completed: _blinkDetected),
          _LivenessCheckItem(
              icon: Icons.sentiment_satisfied,
              label: 'Smile',
              completed: _smileDetected),
          _LivenessCheckItem(
              icon: Icons.turn_left, label: 'Left', completed: _leftTurnDetected),
          _LivenessCheckItem(
              icon: Icons.turn_right,
              label: 'Right',
              completed: _rightTurnDetected),
        ],
      ),
    );
  }

  Widget _buildPreviewScreen() {
    return Stack(
      children: [
        SizedBox.expand(
            child: Image.file(File(_capturedImagePath!), fit: BoxFit.cover)),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
        ),
        // DEBUG OVERLAY
        Positioned(
          top: 60,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.95),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Verification Progress',
                    style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                const SizedBox(height: 4),
                _buildDebugRow('Blink', _blinkDetected),
                _buildDebugRow('Smile', _smileDetected),
                _buildDebugRow('Left Turn', _leftTurnDetected),
                _buildDebugRow('Right Turn', _rightTurnDetected),
                const Divider(color: Colors.white24, height: 8),
                Text(
                    'All Pass: ${_blinkDetected && _smileDetected && _leftTurnDetected && _rightTurnDetected}',
                    style: TextStyle(
                      color: (_blinkDetected &&
                              _smileDetected &&
                              _leftTurnDetected &&
                              _rightTurnDetected)
                          ? Colors.green
                          : Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: const [
                    StepCounterBadge(currentStep: 4, totalSteps: 5)
                  ],
                ),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.verified, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Verification Passed!\nYour identity has been confirmed.',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  children: [
                    PrimaryButton(
                        label: AppStrings.faceConfirm, onPressed: _onConfirm),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: AppStrings.faceRetake,
                      onPressed: _retake,
                      leadingIcon: Icons.refresh_rounded,
                      isDark: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDebugRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TextStyle(
              color: value ? Colors.green : Colors.red,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LivenessCheckItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool completed;

  const _LivenessCheckItem(
      {required this.icon, required this.label, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(completed ? Icons.check_circle : icon,
            size: 20,
            color: completed ? AppColors.success : Colors.white60),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: completed ? AppColors.success : Colors.white60,
            fontWeight: completed ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FaceOvalPainter extends CustomPainter {
  final bool faceDetected;
  final LivenessStep currentStep;

  _FaceOvalPainter({required this.faceDetected, required this.currentStep});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    final screenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final ovalWidth = size.width * 0.65;
    final ovalHeight = size.height * 0.45;
    final ovalLeft = (size.width - ovalWidth) / 2;
    final ovalTop = (size.height - ovalHeight) / 2 - 50;
    final ovalPath = Path()
      ..addOval(Rect.fromLTWH(ovalLeft, ovalTop, ovalWidth, ovalHeight));
    final path =
        Path.combine(PathOperation.difference, screenPath, ovalPath);
    canvas.drawPath(path, overlayPaint);

    Color borderColor;
    if (currentStep == LivenessStep.completed) {
      borderColor = AppColors.success;
    } else if (faceDetected) {
      borderColor = AppColors.gold;
    } else {
      borderColor = Colors.white.withOpacity(0.5);
    }

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawOval(
        Rect.fromLTWH(ovalLeft, ovalTop, ovalWidth, ovalHeight), borderPaint);
  }

  @override
  bool shouldRepaint(_FaceOvalPainter oldDelegate) =>
      oldDelegate.faceDetected != faceDetected ||
      oldDelegate.currentStep != currentStep;
}