import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../domain/usecases/verify_bvn.dart';
import '../../domain/entities/onboarding_progress.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends HydratedBloc<OnboardingEvent, OnboardingState> {
  final VerifyBvn verifyBvn;
  final UploadDocument uploadDocument;
  final UploadFaceCapture uploadFaceCapture;
  final SaveProgress saveProgress;
  final GetSavedProgress getSavedProgress;

  OnboardingBloc({
    required this.verifyBvn,
    required this.uploadDocument,
    required this.uploadFaceCapture,
    required this.saveProgress,
    required this.getSavedProgress,
  }) : super(const OnboardingInitial()) {
    on<SaveConsentEvent>(_onSaveConsent);
    on<SavePersonalInfoEvent>(_onSavePersonalInfo);
    on<VerifyBvnEvent>(_onVerifyBvn);
    on<UploadDocumentEvent>(_onUploadDocument);
    on<UploadFaceCaptureEvent>(_onUploadFaceCapture);
    on<LoadSavedProgressEvent>(_onLoadSavedProgress);
    on<ResetOnboardingEvent>(_onReset);
  }

  // ── Hydration ────────────────────────────────────────────────────────────

  @override
  OnboardingState? fromJson(Map<String, dynamic> json) {
    try {
      final type = json['type'] as String?;
      switch (type) {
        case 'ConsentSaved':
          return const ConsentSaved();
        case 'PersonalInfoSaved':
          return const PersonalInfoSaved();
        case 'BvnVerified':
          return const BvnVerified();
        case 'DocumentUploaded':
          return DocumentUploaded(
            frontImagePath: json['frontImagePath'] as String? ?? '',
          );
        case 'FaceCaptureUploaded':
          return const FaceCaptureUploaded();
        case 'ProgressLoaded':
          return ProgressLoaded(
            progress: OnboardingProgress.fromJson(
              json['progress'] as Map<String, dynamic>,
            ),
          );
        default:
          return const OnboardingInitial();
      }
    } catch (_) {
      return const OnboardingInitial();
    }
  }

  @override
  Map<String, dynamic>? toJson(OnboardingState state) {
    if (state is ConsentSaved) return {'type': 'ConsentSaved'};
    if (state is PersonalInfoSaved) return {'type': 'PersonalInfoSaved'};
    if (state is BvnVerified) return {'type': 'BvnVerified'};
    if (state is DocumentUploaded) {
      return {
        'type': 'DocumentUploaded',
        'frontImagePath': state.frontImagePath,
      };
    }
    if (state is FaceCaptureUploaded) return {'type': 'FaceCaptureUploaded'};
    if (state is ProgressLoaded)
      return {'type': 'ProgressLoaded', 'progress': state.progress.toJson()};
    // Don't persist loading/error/initial states
    return null;
  }

  // ── Handlers (unchanged) ─────────────────────────────────────────────────

  Future<void> _onSaveConsent(
    SaveConsentEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(const ConsentSaved());
  }

  Future<void> _onSavePersonalInfo(
    SavePersonalInfoEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(const PersonalInfoSaved());
  }

  Future<void> _onVerifyBvn(
    VerifyBvnEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading(message: 'Verifying BVN with NIBSS…'));
    final result = await verifyBvn(VerifyBvnParams(bvn: event.bvn));
    result.fold(
      (failure) =>
          emit(OnboardingError(message: failure.message, code: failure.code)),
      (_) => emit(const BvnVerified()),
    );
  }

  Future<void> _onUploadDocument(
    UploadDocumentEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading(message: 'Uploading document…'));
    final result = await uploadDocument(
      UploadDocumentParams(
        documentType: event.documentType,
        frontImagePath: event.frontImagePath,
        backImagePath: event.backImagePath,
      ),
    );
    result.fold(
      (failure) =>
          emit(OnboardingError(message: failure.message, code: failure.code)),
      (_) => emit(DocumentUploaded(frontImagePath: event.frontImagePath)),
    );
  }

  Future<void> _onUploadFaceCapture(
    UploadFaceCaptureEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading(message: 'Analysing biometrics…'));
    final result = await uploadFaceCapture(
      UploadFaceCaptureParams(
        imagePath: event.imagePath,
        livenessVerified: event.livenessVerified,
        livenessData: event.livenessData,
      ),
    );
    result.fold(
      (failure) =>
          emit(OnboardingError(message: failure.message, code: failure.code)),
      (_) => emit(const FaceCaptureUploaded()),
    );
  }

  Future<void> _onLoadSavedProgress(
    LoadSavedProgressEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    final result = await getSavedProgress(const NoParams());
    result.fold((failure) => emit(const OnboardingInitial()), (progressData) {
      final progress = OnboardingProgress.fromJson(progressData);
      emit(ProgressLoaded(progress: progress));
    });
  }

  Future<void> _onReset(
    ResetOnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    await clear(); // clears HydratedBloc storage for this bloc
    emit(const OnboardingInitial());
  }
}
