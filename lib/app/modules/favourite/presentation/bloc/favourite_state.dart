part of 'favourite_bloc.dart';

class FavouriteState extends Equatable {
  final List<FavouriteModel> favourites;
  final bool isLiking;
  final bool isLoading;
  final bool isLiked;
  final bool showSnack;
  final bool isError;
  final String title;
  final String message;

  const FavouriteState({
    this.favourites = const [],
    this.isLiking = false,
    this.isLoading = false,
    this.isLiked = false,
    this.showSnack = false,
    this.isError = false,
    this.title = "",
    this.message = "",
  });

  FavouriteState copyWith({
    List<FavouriteModel>? favourites,
    bool? isLiking,
    bool? isLoading,
    bool? isLiked,
    bool? showSnack,
    bool? isError,
    String? title,
    String? message,
  }) {
    return FavouriteState(
      favourites: favourites ?? this.favourites,
      isLiking: isLiking ?? this.isLiking,
      isLoading: isLoading ?? this.isLoading,
      isLiked: isLiked ?? this.isLiked,
      showSnack: showSnack ?? this.showSnack,
      isError: isError ?? this.isError,
      title: title ?? this.title,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    favourites, isLiking, isLoading,
    isLiked, showSnack, isError, title, message,
  ];
}