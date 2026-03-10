import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/match_faces.dart';
import '../../../../core/ml/face_match_service.dart';
import 'face_match_event.dart';
import 'face_match_state.dart';

class FaceMatchBloc extends Bloc<FaceMatchEvent, FaceMatchState> {
  final MatchFaces matchFaces;
  final FaceMatchService faceMatchService;

  FaceMatchBloc({
    required this.matchFaces,
    required this.faceMatchService,
  }) : super(FaceMatchInitial()) {
    on<MatchFacesRequested>(_onMatchFacesRequested);
  }

  Future<void> _onMatchFacesRequested(
      MatchFacesRequested event, Emitter emit) async {
    emit(FaceMatchLoading());
    final result = await matchFaces(MatchFacesParams(
      selfiePath: event.selfiePath,
      idImagePath: event.idImagePath,
    ));
    result.fold(
      (failure) => emit(FaceMatchError(failure.message)),
      (similarity) => emit(FaceMatchResult(
        similarity: similarity,
        isMatch: faceMatchService.isMatch(similarity),
      )),
    );
  }
}