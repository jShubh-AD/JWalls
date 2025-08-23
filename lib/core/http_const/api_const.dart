class ApiConst {
  static const fetchUser = 'users/';
  static const fetchImageId = 'photos/';
  static const searchWall ='search/photos/';
  static const random = 'photos/random';
  static const key = '?client_id=M0MsVzxFIv1E-bSim_dqnysWneyNWdO2_6ImlkznFgA';
}extension ApiUrls on String {
  String baseUrl(){
    const baseUrl ='https://api.unsplash.com/';
    return baseUrl + this;
  }
}


//uJNokym2lnVuaxCww00FP1DgOoOfXXz4-UnaRnaYsFI


//M0MsVzxFIv1E-bSim_dqnysWneyNWdO2_6ImlkznFgA