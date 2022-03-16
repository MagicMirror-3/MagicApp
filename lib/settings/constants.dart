import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:magic_app/util/utility.dart';

import '../generated/l10n.dart';

/// Contains different Maps of const values.
///
/// The keys represent the saved value in shared preferences, while the values
/// are displayed to the user in the settings
class SettingChoices {
  // No instantiation wanted
  const SettingChoices._();

  /// Every possible wall background the user can choose from
  static Map<String, String> wallPatternChoices(BuildContext context) {
    return LinkedHashMap.from({
      "wall.jpg": S.of(context).defaultString,
      "brick-wall.png": S.of(context).settings_brickWall,
      "brick-wall-dark.png": S.of(context).settings_darkBrickWall,
      "dark-brick-wall.png": S.of(context).settings_darkBrickWall2,
      "concrete-wall.png": S.of(context).settings_concrete,
      "concrete-wall-2.png": S.of(context).settings_concrete2,
      "concrete-wall-3.png": S.of(context).settings_concrete3,
      "redox-01.png": S.of(context).settings_redox,
      "soft-wallpaper.png": S.of(context).settings_soft,
      "white-wall.png": S.of(context).settings_whiteWall,
      "dark-wall.png": S.of(context).settings_darkWall,
    });
  }

  /// Every possible mirror frame the user can choose from
  static Map<String, String> mirrorFrameChoices(BuildContext context) {
    return LinkedHashMap.from({
      "default.png": S.of(context).defaultString,
    });
  }

  /// Every possible language the user can choose from
  static Map<String, String> languageChoices(BuildContext context) {
    return LinkedHashMap.from({
      "en": S.of(context).settings_langEn,
      "de": S.of(context).settings_langDe
    });
  }
}

/// Contains every key of every value saved in the shared preferences
class SettingKeys {
  // No instantiation wanted
  const SettingKeys._();

  /// Whether the application is used for the first time
  static const String firstUse = "firstUse";

  /// The IP-Address of the mirror in the local network
  static const String mirrorAddress = "mirrorAddress";

  /// The logged in user
  static const String user = "user";

  /// Whether a dark theme should be used
  static const String darkMode = "darkMode";

  /// Whether the respectively other platform design should be used
  static const String alternativeAppearance = "alternativeAppearance";

  /// The language the app should be displayed it
  static const String language = "language";

  /// The name of the image which should be used for the wall background
  static const String wallPattern = "wallPattern";

  /// The hex representation of the color of the background wall
  static const String wallColor = "wallColor";

  /// The name of the image which should be used for the frame around the mirror
  static const String mirrorFrame = "mirrorFrame";

  /// Whether the mirror layout should be refreshed by retrieving it from the
  /// backend
  static const String mirrorRefresh = "mirrorRefresh";

  /// Whether the [MirrorEdit] should automatically be closed upon saving with
  /// the green checkmark
  static const String quitOnSave = "quitOnSave";
}

/// The default values to use if no value is present in shared preferences
Map<String, dynamic> defaultValues = {
  SettingKeys.firstUse: true,
  SettingKeys.mirrorAddress: "",
  SettingKeys.user: const MagicUser(
    id: 1,
    firstName: "Default",
    lastName: "Simon",
  ),
  SettingKeys.darkMode: true,
  SettingKeys.alternativeAppearance: false,
  SettingKeys.language: "en",
  SettingKeys.wallPattern: "wall.jpg",
  SettingKeys.wallColor: Colors.white,
  SettingKeys.mirrorFrame: "default.png",
  SettingKeys.mirrorRefresh: true,
  SettingKeys.quitOnSave: true,
};
