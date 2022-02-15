import 'package:flutter/cupertino.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:magic_app/mirror/mirror_data.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHandler {
  static late SharedPreferences _preferences;

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _preferences = await SharedPreferences.getInstance();
  }

  static T getValue<T>(String key, [T? defaultValue]) {
    defaultValue = defaultValue ?? defaultValues[key] as T;

    if (_preferences.get(key) != null) {
      if (defaultValue is Color) {
        return (colorFromHex(_preferences.getString(key) ?? "ffffff") ??
            defaultValue) as T;
      } else if (defaultValue is MirrorLayout) {
        return MirrorLayout.fromString(
            _preferences.getString(SettingKeys.mirrorLayout) ??
                defaultMirrorLayout) as T;
      } else {
        return _preferences.get(key) as T;
      }
    } else {
      saveValue(key, defaultValue);
      return defaultValue as T;
    }
  }

  static void saveValue<T>(String key, T value) {
    if (value is String) {
      _preferences.setString(key, value);
    } else if (value is int) {
      _preferences.setInt(key, value);
    } else if (value is bool) {
      _preferences.setBool(key, value);
    } else if (value is double) {
      _preferences.setDouble(key, value);
    } else if (value is List<String>) {
      _preferences.setStringList(key, value);
    } else if (value is Color) {
      _preferences.setString(key, value.value.toRadixString(16));
    } else if (value is MirrorLayout) {
      // print("Saving mirror layout as ${value.toString()}");
      _preferences.setString(key, value.toString());
    } else {
      throw TypeError();
    }
  }

  static void resetLayout() {
    _preferences.remove(SettingKeys.mirrorLayout);
  }
}
