abstract class FaceMatchState {}

class FaceMatchInitial extends FaceMatchState {}
class FaceMatchLoading extends FaceMatchState {}

class FaceMatchResult extends FaceMatchState {
  final double similarity;
  final bool isMatch;
  FaceMatchResult({required this.similarity, required this.isMatch});
}

class FaceMatchError extends FaceMatchState {
  final String message;
  FaceMatchError(this.message);
}