import 'package:flutter/animation.dart';
import 'package:get/get.dart';

class WallpaperSettingsController extends GetxController
    with SingleGetTickerProviderMixin {
  RxBool isRolling = false.obs;
  late AnimationController lottiController;

  @override
  void onInit() {
    super.onInit();
    lottiController = AnimationController(vsync: this);
  }

  @override
  void onClose() {
    lottiController.dispose();
    super.dispose();
  }

  var constraints = WallpaperConstraintsModel(
    autoSwitch: true,
    wifiOnly: true,
    chargingOnly: false,
    idleOnly: false,
    batteryLow: false,
    interval: Duration(hours: 1),
    source: 'WALLPAPER',
  ).obs;

  // Main toggle - controls if WorkManager should run
  void toggleAutoSwitch(bool value) {
    constraints.value = constraints.value.copyWith(autoSwitch: value);
    constraints.refresh();

    // Here you can start/stop WorkManager based on the value
    if (value) {
      _startWorkManager();
    } else {
      _stopWorkManager();
    }
  }

  // Constraint toggles - these update WorkManager constraints
  void toggleWifiOnly(bool value) {
    constraints.value = constraints.value.copyWith(wifiOnly: value);
    constraints.refresh();
    if (constraints.value.autoSwitch) _updateWorkManagerConstraints();
  }

  void toggleChargingOnly(bool value) {
    constraints.value = constraints.value.copyWith(chargingOnly: value);
    constraints.refresh();
    if (constraints.value.autoSwitch) _updateWorkManagerConstraints();
  }

  void toggleBatteryOnly(bool value) {
    constraints.value = constraints.value.copyWith(batteryLow: value);
    constraints.refresh();
    if (constraints.value.autoSwitch) _updateWorkManagerConstraints();
  }

  void toggleIdleOnly(bool value) {
    constraints.value = constraints.value.copyWith(idleOnly: value);
    constraints.refresh();
    if (constraints.value.autoSwitch) _updateWorkManagerConstraints();
  }

  // Update interval - this sets WorkManager's periodic interval
  void updateInterval(Duration newInterval) {
    constraints.value = constraints.value.copyWith(interval: newInterval);
    constraints.refresh();
    if (constraints.value.autoSwitch) _updateWorkManagerConstraints();
  }

  // Update source - this determines which wallpaper collection to use
  void updateSource(String newSource) {
    constraints.value = constraints.value.copyWith(source: newSource);
    constraints.refresh();
  }

  // WorkManager integration methods
  void _startWorkManager() {
    print('Starting WorkManager with constraints: ${constraints.value}');
  }

  void _stopWorkManager() {
    // TODO: Implement WorkManager.cancelAll()
    print('Stopping WorkManager');
  }

  void _updateWorkManagerConstraints() {
    // TODO: Cancel existing work and restart with new constraints
    print('Updating WorkManager constraints: ${constraints.value}');
    _stopWorkManager();
    _startWorkManager();
  }

  void stopRandomAnimation() {
    lottiController.reset();
    isRolling.value = false;
  }
}

class WallpaperConstraintsModel {
  final bool autoSwitch; // Controls if WorkManager runs
  final bool wifiOnly; // WorkManager constraint: require WiFi
  final bool chargingOnly; // WorkManager constraint: require charging
  final bool idleOnly; // WorkManager constraint: require device idle
  final bool batteryLow; // WorkManager constraint: ignore if battery low
  final Duration interval; // WorkManager periodic interval
  final String source; // Wallpaper source collection

  WallpaperConstraintsModel({
    required this.autoSwitch,
    required this.wifiOnly,
    required this.chargingOnly,
    required this.idleOnly,
    required this.batteryLow,
    required this.interval,
    required this.source,
  });

  // CopyWith method for immutable updates
  WallpaperConstraintsModel copyWith({
    bool? autoSwitch,
    bool? wifiOnly,
    bool? chargingOnly,
    bool? idleOnly,
    bool? batteryLow,
    Duration? interval,
    String? source,
  }) {
    return WallpaperConstraintsModel(
      autoSwitch: autoSwitch ?? this.autoSwitch,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      chargingOnly: chargingOnly ?? this.chargingOnly,
      idleOnly: idleOnly ?? this.idleOnly,
      batteryLow: batteryLow ?? this.batteryLow,
      interval: interval ?? this.interval,
      source: source ?? this.source,
    );
  }
}
