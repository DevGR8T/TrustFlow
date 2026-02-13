import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/verify_bvn.dart';
import '../../domain/usecases/upload_document.dart';
import '../../domain/usecases/upload_face_capture.dart';
import '../../domain/usecases/save_progress.dart';
import '../../domain/usecases/get_saved_progress.dart';
import '../../domain/entities/onboarding_progress.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
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
      (failure) => emit(OnboardingError(
        message: failure.message,
        code: failure.code,
      )),
      (_) => emit(const BvnVerified()),
    );
  }

  Future<void> _onUploadDocument(
    UploadDocumentEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading(message: 'Uploading document…'));
    
    final result = await uploadDocument(UploadDocumentParams(
      documentType: event.documentType,
      frontImagePath: event.frontImagePath,
      backImagePath: event.backImagePath,
    ));
    
    result.fold(
      (failure) => emit(OnboardingError(
        message: failure.message,
        code: failure.code,
      )),
      (_) => emit(const DocumentUploaded()),
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
      livenessVerified: event.livenessVerified,  // ✅ Add this
      livenessData: event.livenessData,          // ✅ Add this
    ),
  );

  result.fold(
    (failure) {
      
      emit(OnboardingError(message: failure.message, code: failure.code));
    },
    (_) {
      
      emit(const FaceCaptureUploaded());
    },
  );
}

  

  Future<void> _onLoadSavedProgress(
    LoadSavedProgressEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    final result = await getSavedProgress(const NoParams());
    
    result.fold(
      (failure) => emit(const OnboardingInitial()),
      (progressData) {
        final progress = OnboardingProgress.fromJson(progressData);
        emit(ProgressLoaded(progress: progress));
      },
    );
  }

  Future<void> _onReset(
    ResetOnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingInitial());
  }
}