import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConst {
  static final apiKey = dotenv.env['API_KEY'];
  static const fetchUser = 'users/';
  static const fetchImageId = 'photos/';
  static const searchWall ='search/photos/';
  static const random = 'photos/random';
  static final key = '?client_id=$apiKey';
}extension ApiUrls on String {
  String baseUrl(){
    const baseUrl ='https://api.unsplash.com/';
    return baseUrl + this;
  }
}