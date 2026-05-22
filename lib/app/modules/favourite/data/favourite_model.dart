import '../../home/data/wallaper_response_modle.dart';

class FavouriteModel {
  final String? id;
  final String? imagePath;
  final Urls? urls;
  final User? user;

  FavouriteModel({this.imagePath,this.id, this.urls, this.user});

  factory FavouriteModel.fromJson(Map<String, dynamic> json) => FavouriteModel(
    id: json['id'],
    imagePath: json['imagePath'],
    urls: json['urls'] != null ? Urls.fromJson(json['urls']) : null,
    user: json['user'] != null ? User.fromJson(json['user']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'urls': urls?.toJson(),
    'user': user?.toJson(),
  };
}