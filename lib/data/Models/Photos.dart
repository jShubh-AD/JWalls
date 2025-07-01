import 'Urls.dart';
import 'dart:convert';

Photos photosFromJson(String str) => Photos.fromJson(json.decode(str));
String photosToJson(Photos data) => json.encode(data.toJson());
class Photos {
  Photos({
      this.id, 
      this.slug, 
      this.createdAt, 
      this.updatedAt, 
      this.blurHash, 
      this.assetType, 
      this.urls,});

  Photos.fromJson(dynamic json) {
    id = json['id'];
    slug = json['slug'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    blurHash = json['blur_hash'];
    assetType = json['asset_type'];
    urls = json['urls'] != null ? Urls.fromJson(json['urls']) : null;
  }
  String? id;
  String? slug;
  String? createdAt;
  String? updatedAt;
  String? blurHash;
  String? assetType;
  Urls? urls;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['slug'] = slug;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['blur_hash'] = blurHash;
    map['asset_type'] = assetType;
    if (urls != null) {
      map['urls'] = urls?.toJson();
    }
    return map;
  }

}