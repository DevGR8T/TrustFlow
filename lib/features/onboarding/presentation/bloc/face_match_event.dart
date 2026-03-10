abstract class FaceMatchEvent {}

class MatchFacesRequested extends FaceMatchEvent {
  final String selfiePath;
  final String idImagePath;
  MatchFacesRequested({
    required this.selfiePath,
    required this.idImagePath,
  });
}