class Wallpaper {
  final String? id;
  final num? width;
  final num? height;
  final Urls? urls;
  final ProfileImage? avatar;
  final String? userName;
  final String? name;

  Wallpaper({
    this.id,
    this.width,
    this.height,
    this.urls,
    this.avatar,
    this.userName,
    this.name,
  });

  factory Wallpaper.fromJson(Map<String, dynamic> json) => Wallpaper(
    id: json['id'],
    width: json['width'],
    height: json['height'],
    urls: json['urls'] != null ? Urls.fromJson(json['urls']) : null,
    avatar: json['user']?['profile_image'] != null
        ? ProfileImage.fromJson(json['user']['profile_image'])
        : null,
    userName: json['user']?['username'],
    name: json['user']?['name'],
  );

  static List<Wallpaper> fromJsonList(dynamic json) =>
      (json as List).map((e) => Wallpaper.fromJson(e)).toList();
}

class ProfileImage {
  final String? small;
  final String? medium;
  final String? large;

  ProfileImage({this.small, this.medium, this.large});

  factory ProfileImage.fromJson(Map<String, dynamic> json) => ProfileImage(
    small: json['small'],
    medium: json['medium'],
    large: json['large'],
  );
}

class Urls {
  final String? full;
  final String? regular;
  final String? small;

  Urls({this.full, this.regular, this.small});

  factory Urls.fromJson(Map<String, dynamic> json) => Urls(
    full: json['full'],
    regular: json['regular'],
    small: json['small'],
  );
}