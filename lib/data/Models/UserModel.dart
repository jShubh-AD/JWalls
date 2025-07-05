import 'Links.dart';
import 'ProfileImage.dart';
import 'Photos.dart';
import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));
String userModelToJson(UserModel data) => json.encode(data.toJson());
class UserModel {
  UserModel({
      this.id,
      this.name,
      this.bio,
      this.links, 
      this.profileImage,
      this.photos,});

  UserModel.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    bio = json['bio'];
    links = json['links'] != null ? Links.fromJson(json['links']) : null;
    profileImage = json['profile_image'] != null ? ProfileImage.fromJson(json['profile_image']) : null;
    if (json['photos'] != null) {
      photos = [];
      json['photos'].forEach((v) {
        photos?.add(Photos.fromJson(v));
      });
    }
  }
  String? id;
  String? name;
  String? bio;
  Links? links;
  ProfileImage? profileImage;
  List<Photos>? photos;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['bio'] = bio;
    if (links != null) {
      map['links'] = links?.toJson();
    }
    if (profileImage != null) {
      map['profile_image'] = profileImage?.toJson();
    }
    if (photos != null) {
      map['photos'] = photos?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}