part of 'view_image_bloc.dart';

enum EditStatus { initial, editing, done }

class ViewImageState extends Equatable {
  final EditStatus editStatus;
  final String title;
  final double blur;
  final bool isSettingWall;
  final bool isDownloading;
  final bool isError;
  final bool showSnack;
  final String message;

  const ViewImageState({
    this.editStatus = EditStatus.initial,
    this.blur = 0.0,
    this.isDownloading = false,
    this.isSettingWall = false,
    this.isError = false,
    this.showSnack = false,
    this.title = "",
    this.message = "",
  });

  ViewImageState copyWith({
    final EditStatus? editStatus,
    final String? title,
    final double? blur,
    final bool? isSettingWall,
    final bool? isDownloading,
    final bool? isError,
    final bool? showSnack,
    final String? message,
  }) {
    return ViewImageState(
      editStatus: editStatus ?? this.editStatus,
      blur: blur ?? this.blur,
      isSettingWall: isSettingWall ?? this.isSettingWall,
      isDownloading: isDownloading ?? this.isDownloading,
      title: title ?? this.title,
      message: message ?? this.message,
      isError: isError ?? this.isError,
      showSnack: showSnack ?? this.showSnack,
    );
  }

  @override
  List<Object?> get props => [
    blur,
    editStatus,
    title,
    message,
    isError,
    isSettingWall,
    isDownloading,
  ];
}
