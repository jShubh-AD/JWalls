import 'package:get/get.dart';

import '../data/DataSource/user_datasource.dart';
import '../data/Models/UserModel.dart';

class FetchUser extends GetxController{

  final _repo = User_Datasource();

  Rx<bool> isUserLoading = false.obs;
  final user = Rxn<PhotographerResponseModel>();


  Future<PhotographerResponseModel?> loadUser (String id) async{
    isUserLoading.value = true;
    user.value = await _repo.fetchUser(id);
    isUserLoading.value = false;
    return user.value;
  }
}