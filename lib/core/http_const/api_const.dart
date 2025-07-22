class ApiConst {
  static const fetchUser = 'users/';
  static const fetchImageId = 'photos/';
  static const searchWall ='search/photos/';
  static const key = '?client_id=DCje4HfwT2SX_n9_dkWieoD9wdZunsmouRNTJ_NWKN8';
}extension ApiUrls on String {
  String baseUrl(){
    const baseUrl ='https://api.unsplash.com/';
    return baseUrl + this;
  }
}


//uJNokym2lnVuaxCww00FP1DgOoOfXXz4-UnaRnaYsFI