import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:walpy/core/shared_preferences.dart';

class WallpaperSettingsController extends GetxController with SingleGetTickerProviderMixin {
  RxBool isRolling = false.obs;
  late AnimationController lottiController;
  RxBool autoSwitch = true.obs;
  RxBool wifiOnly = true.obs;
  RxBool chargingOnly = false.obs;
  RxBool idleOnly = false.obs;
  RxBool batteryLow = false.obs;
  Rx<Duration> interval = const Duration(hours: 1).obs;



  @override
  void onInit() {
    super.onInit();
    _loadPrefs();
    lottiController = AnimationController(vsync: this);
  }

  @override
  void onClose() {
    lottiController.dispose();
    super.dispose();
  }

  void stopRandomAnimation() {
    lottiController.reset();
    isRolling.value = false;
  }


  Future<void> _loadPrefs() async {
    autoSwitch.value = await SharePreferences().getAutoSwitch() ?? false;
    wifiOnly.value = await SharePreferences().getWifiOnly() ?? false;
    chargingOnly.value = await SharePreferences().getChargingOnly() ?? false;
    idleOnly.value = await SharePreferences().getIdleOnly() ?? false;
    batteryLow.value = await SharePreferences().getBatteryLow() ?? false;
    interval.value = (await SharePreferences().getInterval()) as Duration ;
  }



  /// Toggle buttons

  void toggleAutoSwitch(bool val) {
    autoSwitch.value = val;
    SharePreferences().setAutoSwitch(autoSwitch: val);
    print('autoswitch: $val');
  }

  void toggleWifiOnly(bool val) {
    wifiOnly.value = val;
    SharePreferences().setWifiOnly(wifiOnly: val);
    print('wifi: $val');
  }

  void toggleChargingOnly(bool val) {
    chargingOnly.value = val;
    SharePreferences().setChargingOnly(chargingOnly:val);
    print('charging: $val');
  }

  void toggleIdleOnly(bool val) {
    idleOnly.value = val;
    SharePreferences().setIdleOnly(idleOnly: val);
    print('ideal: $val');
  }

  void toggleBatteryLow(bool val) {
    batteryLow.value = val;
    SharePreferences().setBatteryLow(batteryLow: val);
    print('battery Low: $val');
  }

  void updateInterval(Duration val) {
    interval.value = val;
    SharePreferences().setInterval(interval: val);
    print('interval: $val');
  }

}
