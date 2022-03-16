import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/util/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mirror/mirror_layout_handler.dart';

/// Handles the persistent saving and retrieving of values on the local device storage.
class SharedPreferencesHandler {
  const SharedPreferencesHandler._();

  static late SharedPreferences _preferences;

  /// Initialize the handler
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _preferences = await SharedPreferences.getInstance();
  }

  /// Tries retrieving the value of the class [T] with the given [key].
  ///
  /// If the [key] is not present, it returns the given [defaultValue].
  /// Usually, they [key] is a member of the class [SettingKeys]. This way, it is
  /// ensured, that a [defaultValue] exists.
  static T getValue<T>(String key, [T? defaultValue]) {
    // Get the persistent default value if none is given
    defaultValue = defaultValue ?? defaultValues[key] as T;

    if (_preferences.get(key) != null) {
      // Color and MagicUser values need special treatment, because they are saved as strings
      if (defaultValue is Color) {
        // Convert the string to a color
        return (colorFromHex(_preferences.getString(key) ?? "ffffff") ??
            defaultValue) as T;
      } else if (defaultValue is MagicUser) {
        return MagicUser.fromJSON(
            jsonDecode(_preferences.getString(SettingKeys.user) ?? "")) as T;
      } else {
        // No special treatment needed
        return _preferences.get(key) as T;
      }
    } else {
      // This is an unknown key, save it and return the default value
      saveValue(key, defaultValue);
      return defaultValue as T;
    }
  }

  /// Persists the [value] of a given [key] to local storage.
  ///
  /// Throws [TypeError] if the class [T] is unknown.
  static void saveValue<T>(String key, T value) {
    // Use a special method depending on the class of the value
    // Color and MirrorLayout have to be converted back to a string
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
    } else if (value is MagicUser) {
      _preferences.setString(key, value.toString());
    } else {
      // Unknown class T of value
      throw TypeError();
    }
  }

  static void resetKey(String key) {
    _preferences.remove(key);
  }
}
