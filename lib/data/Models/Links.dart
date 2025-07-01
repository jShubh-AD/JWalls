import 'dart:convert';

Links linksFromJson(String str) => Links.fromJson(json.decode(str));
String linksToJson(Links data) => json.encode(data.toJson());
class Links {
  Links({
      this.html,});

  Links.fromJson(dynamic json) {
    html = json['html'];
  }
  String? html;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['html'] = html;
    return map;
  }

}