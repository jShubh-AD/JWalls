part of 'artist_bloc.dart';

sealed class ArtistEvent extends Equatable {
  const ArtistEvent();

  @override
  List<Object?> get props => [];
}

class FetchArtistPhotos extends ArtistEvent {
  final String username;
  const FetchArtistPhotos(this.username);

  @override
  List<Object?> get props => [username];
}

class FetchNextArtistPhotosPage extends ArtistEvent {}

