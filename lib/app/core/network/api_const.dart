import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiConst {
  static final apiKey = dotenv.env['API_KEY'];
  static const baseUrl ='https://api.unsplash.com/';

  // Endpoints
  static const fetchUser = 'users/';
  static const fetchImages = 'photos/';
  static const searchWall ='search/photos/';
  static const random = 'photos/random';
  // static final key = '?client_id=$apiKey';

  // Query Params
  static final key = '?client_id=$apiKey';
  static const per_page = 20;

  // Timeout durations
  static const connectTimeout= Duration(seconds: 5);
  static const receiveTimeout = Duration(seconds: 5);
  static const sendTimeout = Duration(seconds: 5);
}