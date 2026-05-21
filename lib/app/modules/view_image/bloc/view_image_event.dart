part of 'view_image_bloc.dart';

sealed class ViewImageEvent extends Equatable {
  const ViewImageEvent();

  @override
  List<Object?> get props => [];
}

class ViewImageSetWall extends ViewImageEvent{
  final GlobalKey boundaryKey;

  const ViewImageSetWall(this.boundaryKey);
  @override
  List<Object> get props => [boundaryKey];
}

class ViewImageLikeWall extends ViewImageEvent{}

// Download Wall Events
class DownloadWall extends ViewImageEvent{
  final GlobalKey boundaryKey;
  final String? url;
  final Uint8List? bytes;
  const DownloadWall({required this.boundaryKey, this.url, this.bytes});

  @override
  List<Object?> get props => [boundaryKey, url, bytes];
}

// Edit Wall Events
class EditingWall extends ViewImageEvent{}

class EditWallBlurChanged extends ViewImageEvent{
  final double blur;
  const EditWallBlurChanged({required this.blur});
  @override
  List<Object> get props => [blur];
}

class EditingWallCancel extends ViewImageEvent{}

class EditingWallDone extends ViewImageEvent{}




