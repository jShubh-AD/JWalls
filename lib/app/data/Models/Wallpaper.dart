class OldWallpaperModle {
  OldWallpaperModle({
    String? id,
    num? width,
    num? height,
    String? color,
    Urls? urls,
    ProfileImage? avatar,
    String? userName,
    String? name,
  }) {
    id = id;
    width = width;
    height = height;
    color = color;
    urls = urls;
    avatar = avatar;
    userName = userName;
    name = name;
  }

  static List<OldWallpaperModle> fromJsonList(dynamic json) {
    return (json as List).map((e) => OldWallpaperModle.fromJson(e)).toList();
  }

  OldWallpaperModle.fromJson(dynamic json) {
    _id = json['id'];
    _width = json['width'];
    _height = json['height'];
    _color = json['color'];
    _urls = json['urls'] != null ? Urls.fromJson(json['urls']) : null;
    _avatar = (json['user']?['profile_image'] != null)
        ? ProfileImage.fromJson(json['user']['profile_image'])
        : null;
    _userName = json['user']?['username'];
    _name = json['user']?['name'];
  }

  String? _id;
  num? _width;
  num? _height;
  String? _color;
  Urls? _urls;
  ProfileImage? _avatar;
  String? _userName;
  String? _name;

  String? get id => _id;

  num? get width => _width;

  num? get height => _height;

  String? get color => _color;

  Urls? get urls => _urls;

  ProfileImage? get avatar => _avatar;

  String? get userName => _userName;

  String? get name => _name;
}

class ProfileImage {
  ProfileImage({String? small, String? medium, String? large}) {
    _small = small;
    _medium = medium;
    _large = large;
  }

  ProfileImage.fromJson(dynamic json) {
    _small = json['small'];
    _medium = json['medium'];
    _large = json['large'];
  }

  String? _small;
  String? _medium;
  String? _large;

  String? get small => _small;

  String? get medium => _medium;

  String? get large => _large;
}

class Urls {
  Urls({
    String? raw,
    String? full,
    String? regular,
    String? small,
    String? thumb,
    String? smallS3,
  }) {
    _raw = raw;
    _full = full;
    _regular = regular;
    _small = small;
    _thumb = thumb;
    _smallS3 = smallS3;
  }

  Urls.fromJson(dynamic json) {
    _raw = json['raw'];
    _full = json['full'];
    _regular = json['regular'];
    _small = json['small'];
    _thumb = json['thumb'];
    _smallS3 = json['small_s3'];
  }

  String? _raw;
  String? _full;
  String? _regular;
  String? _small;
  String? _thumb;
  String? _smallS3;

  String? get raw => _raw;

  String? get full => _full;

  String? get regular => _regular;

  String? get small => _small;

  String? get thumb => _thumb;

  String? get smallS3 => _smallS3;
}
