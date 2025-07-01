class ApiConst {
  static const fetchUser = '/users';
  static const fetchImageId = '/photos';
  static const key = '?client_id=uJNokym2lnVuaxCww00FP1DgOoOfXXz4-UnaRnaYsFI';
}extension ApiUrls on String {
  String baseUrl(){
    const baseUrl ='https://api.unsplash.com';
    return baseUrl + this;
  }
}