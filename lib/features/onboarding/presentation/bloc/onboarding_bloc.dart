import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_data.dart';
import '../../domain/entities/onboarding_progress.dart';
import '../../domain/usecases/verify_bvn.dart';
import '../../domain/usecases/upload_document.dart';
import '../../domain/usecases/upload_face_capture.dart';
import '../../domain/usecases/save_progress.dart';
import '../../domain/usecases/get_saved_progress.dart';
import '../../domain/repositories/verification_repository.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

/// Onboarding BLoC
/// Handles all business logic and state transitions for onboarding
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final VerifyBvn verifyBvnUseCase;
  final UploadDocument uploadDocumentUseCase;
  final UploadFaceCapture uploadFaceCaptureUseCase;
  final SaveProgress saveProgressUseCase;
  final GetSavedProgress getSavedProgressUseCase;
  final VerificationRepository repository;

  // Store user data across the flow
  UserData _userData = const UserData();
  OnboardingProgress _progress = OnboardingProgress.initial();

  OnboardingBloc({
    required this.verifyBvnUseCase,
    required this.uploadDocumentUseCase,
    required this.uploadFaceCaptureUseCase,
    required this.saveProgressUseCase,
    required this.getSavedProgressUseCase,
    required this.repository,
  }) : super(OnboardingInitial()) {
    on<ConsentGiven>(_onConsentGiven);
    on<PersonalInfoSubmitted>(_onPersonalInfoSubmitted);
    on<BvnSubmitted>(_onBvnSubmitted);
    on<DocumentSubmitted>(_onDocumentSubmitted);
    on<FaceCaptureSubmitted>(_onFaceCaptureSubmitted);
    on<VerificationStatusChecked>(_onVerificationStatusChecked);
    on<LoadSavedProgress>(_onSavedProgressLoaded); 
    on<OnboardingRestarted>(_onOnboardingRestarted);
  }

  // ==========================================================================
  // EVENT HANDLERS
  // ==========================================================================

  /// Handle consent given
  Future<void> _onConsentGiven(
    ConsentGiven event,
    Emitter<OnboardingState> emit,
  ) async {
    _progress = _progress.copyWith(
      currentStep: OnboardingStep.personalInfo,
      isConsentGiven: true,
    );

    await saveProgressUseCase(_progress, _userData);
    emit(ConsentAccepted());
  }

  /// Handle personal info submission
  Future<void> _onPersonalInfoSubmitted(
    PersonalInfoSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(PersonalInfoSaving());

    // Update user data
    _userData = _userData.copyWith(
      fullName: event.fullName,
      dateOfBirth: event.dateOfBirth,
      phoneNumber: event.phoneNumber,
      email: event.email,
    );

    // Update progress
    _progress = _progress.copyWith(
      currentStep: OnboardingStep.bvnVerification,
      isPersonalInfoComplete: true,
    );

    // Save progress
    await saveProgressUseCase(_progress, _userData);

    emit(PersonalInfoSaved(userData: _userData));
  }

  /// Handle BVN submission
  Future<void> _onBvnSubmitted(
    BvnSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(BvnVerificationLoading());

    try {
      // Call use case
      final result = await verifyBvnUseCase(event.bvn);

      if (result.isSuccessful) {
        // Update user data with BVN
        _userData = _userData.copyWith(bvn: event.bvn);

        // Update progress
        _progress = _progress.copyWith(
          currentStep: OnboardingStep.documentCapture,
          isBvnVerified: true,
        );

        // Save progress
        await saveProgressUseCase(_progress, _userData);

        emit(BvnVerificationSuccess(
          verifiedData: result.data ?? {},
        ));
      } else {
        emit(BvnVerificationError(message: result.message));
      }
    } catch (e) {
      emit(BvnVerificationError(message: e.toString()));
    }
  }

  /// Handle document submission
  Future<void> _onDocumentSubmitted(
    DocumentSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(DocumentUploading());

    try {
      // Call use case
      final result = await uploadDocumentUseCase(event.imagePath);

      if (result.isSuccessful) {
        // Update progress
        _progress = _progress.copyWith(
          currentStep: OnboardingStep.faceCapture,
          isDocumentUploaded: true,
        );

        // Save progress
        await saveProgressUseCase(_progress, _userData);

        final documentId = result.data?['documentId'] ?? 'unknown';
        emit(DocumentUploadSuccess(documentId: documentId));
      } else {
        emit(DocumentUploadError(message: result.message));
      }
    } catch (e) {
      emit(DocumentUploadError(message: e.toString()));
    }
  }

  /// Handle face capture submission
  Future<void> _onFaceCaptureSubmitted(
    FaceCaptureSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(FaceUploading());

    try {
      // Call use case
      final result = await uploadFaceCaptureUseCase(event.imagePath);

      if (result.isSuccessful) {
        // Update progress
        _progress = _progress.copyWith(
          currentStep: OnboardingStep.verification,
          isFaceCaptured: true,
        );

        // Save progress
        await saveProgressUseCase(_progress, _userData);

        final faceId = result.data?['faceId'] ?? 'unknown';
        emit(FaceUploadSuccess(faceId: faceId));
      } else {
        emit(FaceUploadError(message: result.message));
      }
    } catch (e) {
      emit(FaceUploadError(message: e.toString()));
    }
  }

  /// Handle verification status check
  Future<void> _onVerificationStatusChecked(
    VerificationStatusChecked event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(VerificationPending());

    try {
      final result = await repository.checkVerificationStatus();

      if (result.isSuccessful) {
        // Update progress
        _progress = _progress.copyWith(
          currentStep: OnboardingStep.complete,
          isVerificationComplete: true,
        );

        // Save progress
        await saveProgressUseCase(_progress, _userData);

        emit(VerificationApproved(userData: result.data));
      } else {
        emit(VerificationFailed(
          message: result.message,
          canRetry: result.data?['canRetry'] ?? true,
        ));
      }
    } catch (e) {
      emit(VerificationFailed(
        message: e.toString(),
        canRetry: true,
      ));
    }
  }

  /// Handle loading saved progress
  Future<void> _onSavedProgressLoaded(
    LoadSavedProgress event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(LoadingSavedProgress());

    try {
      final progress = await getSavedProgressUseCase();
      final userData = await repository.getSavedUserData();

      if (progress != null && userData != null) {
        _progress = progress;
        _userData = userData;

        emit(SavedProgressLoaded(
          progress: progress,
          userData: userData,
        ));
      } else {
        emit(NoSavedProgress());
      }
    } catch (e) {
      emit(OnboardingError(message: e.toString()));
    }
  }

  /// Handle onboarding restart
  Future<void> _onOnboardingRestarted(
    OnboardingRestarted event,
    Emitter<OnboardingState> emit,
  ) async {
    await repository.clearAllData();
    _userData = const UserData();
    _progress = OnboardingProgress.initial();
    emit(OnboardingInitial());
  }
}