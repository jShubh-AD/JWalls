import 'package:shared_preferences/shared_preferences.dart';

class SharePreferences {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences once at app startup
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Get the initialized SharedPreferences instance
  SharedPreferences get _pref {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized. Call SharePreferences.init() first.');
    }
    return _prefs!;
  }

  /// Set

  void setAutoSwitch({required bool? autoSwitch}) async{
    final prefs = _pref;
    prefs.setBool('autoSwitch', autoSwitch ?? true );
  }

  void setWifiOnly({required bool? wifiOnly}) async{
    final prefs = _pref;
    prefs.setBool('wifiOnly', wifiOnly ?? true );
  }

  void setChargingOnly({required bool? chargingOnly}) async{
    final prefs = _pref;
    prefs.setBool('chargingOnly', chargingOnly ?? false);
  }

  void setIdleOnly({required bool? idleOnly}) async{
    final prefs = _pref;
    prefs.setBool('idleOnly', idleOnly ?? false);
  }

  void setBatteryLow({required bool? batteryLow}) async{
    final prefs = _pref;
    prefs.setBool('batteryLow', batteryLow ?? false);
  }

  void setInterval({required Duration? interval}) async{
    final prefs = _pref;
    final safeInterval = interval ?? Duration(hours: 1);
    prefs.setInt('interval', safeInterval.inMilliseconds);
  }

  /// GET

  Future<bool?> getAutoSwitch()async{
    final prefs = _pref;
    return prefs.getBool('autoSwitch');
  }

  Future<bool?> getWifiOnly()async{
    final prefs = _pref;
    return prefs.getBool('wifiOnly');
  }
  Future<bool?> getChargingOnly()async{
    final prefs = _pref;
    return prefs.getBool('chargingOnly');
  }
  Future<bool?> getIdleOnly()async{
    final prefs = _pref;
    return prefs.getBool('idleOnly');
  }
  Future<bool?> getBatteryLow()async{
    final prefs = _pref;
    return prefs.getBool('batteryLow');
  }
  Future<Duration?> getInterval()async{
    final prefs = _pref;
    final ms = prefs.getInt('interval');
    if (ms == null) {
      return Duration(hours: 1);
    }
    return Duration(milliseconds: ms);
  }

  Future<Map<String, dynamic>> getAllConstraints() async {
    return {
      'autoSwitch': await getAutoSwitch() ?? true,
      'wifiOnly': await getWifiOnly() ?? true,
      'chargingOnly': await getChargingOnly() ?? false,
      'idleOnly': await getIdleOnly() ?? false,
      'batteryLow': await getBatteryLow() ?? false,
      'interval': (await getInterval())?.inMilliseconds ?? Duration(hours: 1).inMilliseconds,
    };
  }

}