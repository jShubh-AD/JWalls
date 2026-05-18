import 'dart:convert';

class ProfileImage {
  ProfileImage({
      this.small,
      this.medium,
      this.large,});

  ProfileImage.fromJson(dynamic json) {
    small = json['small'];
    medium = json['medium'];
    large = json['large'];
  }
  String? small;
  String? medium;
  String? large;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['small'] = small;
    map['medium'] = medium;
    map['large'] = large;
    return map;
  }

}