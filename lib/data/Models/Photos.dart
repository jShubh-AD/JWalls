import 'Urls.dart';
import 'dart:convert';

Photos photosFromJson(String str) => Photos.fromJson(json.decode(str));
String photosToJson(Photos data) => json.encode(data.toJson());
class Photos {
  Photos({
      this.id,
      this.blurHash,
      this.urls,});

  Photos.fromJson(dynamic json) {
    id = json['id'];
    blurHash = json['blur_hash'];
    urls = json['urls'] != null ? Urls.fromJson(json['urls']) : null;
  }
  String? id;
  String? blurHash;
  Urls? urls;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['blur_hash'] = blurHash;
    if (urls != null) {
      map['urls'] = urls?.toJson();
    }
    return map;
  }

}