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
        return MagicUser.fromJSON(jsonDecode(_preferences.getString(key) ?? ""))
            as T;
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

  /// Removes the given [key] from storage and therefore deletes any value associated with it
  static void resetKey(String key) {
    _preferences.remove(key);
  }
}

class PreferencesAdapter {
  const PreferencesAdapter._();

  /// Whether the application is used for the first time and should show an
  /// [IntroductionScreen]
  static bool get isFirstUse =>
      SharedPreferencesHandler.getValue(SettingKeys.firstUse);

  /// Update the firstUse value. Typically called after the introduction is over
  static void setFirstUse(bool value) =>
      SharedPreferencesHandler.saveValue(SettingKeys.firstUse, value);

  /// Whether the layout should be fetched again from the database
  static bool get mirrorRefresh =>
      SharedPreferencesHandler.getValue(SettingKeys.mirrorRefresh);

  /// Sets whether the layout should be fetched again from the database
  static void setMirrorRefresh(bool value) =>
      SharedPreferencesHandler.saveValue(SettingKeys.mirrorRefresh, value);

  /// The IP address of the MagicMirror
  static String get mirrorAddress =>
      SharedPreferencesHandler.getValue(SettingKeys.mirrorAddress);

  /// Sets the IP address of the MagicMirror. Usually called after a successful
  /// connection
  static void setMirrorAddress(String value) =>
      SharedPreferencesHandler.saveValue(SettingKeys.mirrorAddress, value);

  /// The currently logged in user
  static MagicUser get activeUser =>
      SharedPreferencesHandler.getValue(SettingKeys.user);

  /// Updates the logged in user. Usually called after a new user was created or
  /// selected from the list
  static void setActiveUser(MagicUser value) {
    SharedPreferencesHandler.saveValue(SettingKeys.user, value);
    SharedPreferencesHandler.saveValue(SettingKeys.tempUser, value);
  }

  /// A temporary [MagicUser] object to make changes to
  static MagicUser get tempUser =>
      SharedPreferencesHandler.getValue(SettingKeys.tempUser);

  /// Updates the temporary user. Usually called after the profile was edited
  /// and not yet saved
  static void setTempUser(MagicUser value) =>
      SharedPreferencesHandler.saveValue(SettingKeys.tempUser, value);

  /// Whether the app is in dark mode. This is always [true] (for now)
  static bool get isDarkMode =>
      SharedPreferencesHandler.getValue(SettingKeys.darkMode);

  /// Whether to display the app in iOS layout on Android or vice versa
  static bool get isAltAppearance =>
      SharedPreferencesHandler.getValue(SettingKeys.alternativeAppearance);

  /// Update the alternativeAppearance. [true] means that the other design is
  /// used
  static void setAlternativeAppearance(bool value) =>
      SharedPreferencesHandler.saveValue(
        SettingKeys.alternativeAppearance,
        value,
      );

  /// The language code to display the app in. Only "de" and "en" are supported
  static String get language =>
      SharedPreferencesHandler.getValue(SettingKeys.language);

  /// Updates the language of the application. Only "de" and "en" are accepted
  static void setLanguage(String value) =>
      SharedPreferencesHandler.saveValue(SettingKeys.language, value);

  /// The name of the image to use as a background pattern.
  static String get wallPattern =>
      SharedPreferencesHandler.getValue(SettingKeys.wallPattern);

  /// Sets the name of the image to use as a background pattern.
  static void setWallPattern(String value) =>
      SharedPreferencesHandler.saveValue(SettingKeys.wallPattern, value);

  /// The color of the wall behind the mirror
  static Color get wallColor =>
      SharedPreferencesHandler.getValue(SettingKeys.wallColor);

  /// Sets the color of the wall behind the mirror
  static void setWallColor(Color value) =>
      SharedPreferencesHandler.saveValue(SettingKeys.wallColor, value);

  /// The name of the image to use as a frame around the mirror.
  static String get mirrorFrame =>
      SharedPreferencesHandler.getValue(SettingKeys.mirrorFrame);

  /// Sets the name of the image to use as a frame around the mirror.
  static void setMirrorFrame(String value) =>
      SharedPreferencesHandler.saveValue(SettingKeys.mirrorFrame, value);

  /// Whether [MirrorEdit] is quit automatically once the user saves the layout
  static bool get quitOnSave =>
      SharedPreferencesHandler.getValue(SettingKeys.quitOnSave);

  /// Sets whether [MirrorEdit] is quit automatically once the user saves the layout
  static void setQuitOnSave(bool value) =>
      SharedPreferencesHandler.saveValue(SettingKeys.quitOnSave, value);
}
