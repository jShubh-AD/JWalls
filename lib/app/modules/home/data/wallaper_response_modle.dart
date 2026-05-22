class Wallpaper {
  final String? id;
  final num? width;
  final num? height;
  final Urls? urls;
  final User? user;

  Wallpaper({this.id, this.width, this.height, this.urls, this.user});

  factory Wallpaper.fromJson(Map<String, dynamic> json) => Wallpaper(
    id: json['id'],
    width: json['width'],
    height: json['height'],
    user: json['user'] != null ? User.fromJson(json['user']) : null,
    urls: json['urls'] != null ? Urls.fromJson(json['urls']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'width': width,
    'height': height,
    'urls': urls?.toJson(),
    'user': user?.toJson(),
  };

  static List<Wallpaper> fromJsonList(dynamic json) =>
      (json as List).map((e) => Wallpaper.fromJson(e)).toList();
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

  Map<String, dynamic> toJson() => {
    'full': full,
    'regular': regular,
    'small': small,
  };
}

class User {
  String? id;
  String? username;
  String? name;
  String? bio;
  String? location;
  String? link;
  ProfileImage? profileImage;

  User({this.id, this.username, this.name, this.bio, this.location, this.link, this.profileImage});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    name = json['name'];
    bio = json['bio'];
    location = json['location'];
    link = json['links']['html'] ?? "";
    profileImage = json['profile_image'] != null
        ? ProfileImage.fromJson(json['profile_image'])
        : null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'name': name,
    'bio': bio,
    'location': location,
    'links': {'html': link},
    'profile_image': profileImage?.toJson(),
  };
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

  Map<String, dynamic> toJson() => {
    'small': small,
    'medium': medium,
    'large': large,
  };
}