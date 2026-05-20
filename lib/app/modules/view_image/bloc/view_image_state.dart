part of 'view_image_bloc.dart';

sealed class ViewImageState extends Equatable {
  const ViewImageState();

  @override
  List<Object> get props => [];
}

final class ViewImageInitial extends ViewImageState {}

final class ViewImageSetWallState extends ViewImageState{}

final class SetWallResultState extends ViewImageState{
  final String title;
  final bool isError;
  final String message;
  const SetWallResultState(this.title, this.message, {required this.isError});
  @override
  List<Object> get props => [title, message, isError];
}

final class LikeWallState extends ViewImageState{}

final class DownloadWallState extends ViewImageState{}

final class EditWallState extends ViewImageState{}
