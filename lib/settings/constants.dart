import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:magic_app/mirror/mirror_data.dart';

import '../generated/l10n.dart';

class SettingChoices {
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

  static Map<String, String> mirrorBorderChoices(BuildContext context) {
    return LinkedHashMap.from({
      "default.png": S.of(context).defaultString,
    });
  }

  static Map<String, String> languageChoices(BuildContext context) {
    return LinkedHashMap.from({
      "en": S.of(context).settings_langEn,
      "de": S.of(context).settings_langDe
    });
  }
}

class SettingKeys {
  static const String macAddress = "mirrorMAC";

  static const String userName = "userName";

  static const String darkMode = "darkMode";
  static const String alternativeAppearance = "alternativeAppearance";
  static const String language = "language";

  static const String mirrorLayout = "mirrorLayout";
  static const String wallPattern = "wallPattern";
  static const String wallColor = "wallColor";
  static const String mirrorFrame = "mirrorBorder";
  static const String mirrorRefresh = "mirrorRefresh";

  static const String quitOnSave = "quitOnSave";
}

var defaultValues = {
  SettingKeys.macAddress: "",
  SettingKeys.userName: "Default",
  SettingKeys.darkMode: true,
  SettingKeys.alternativeAppearance: false,
  SettingKeys.language: "en",
  SettingKeys.mirrorLayout: MirrorLayout.fromString(defaultMirrorLayout),
  SettingKeys.wallPattern: "wall.jpg",
  SettingKeys.wallColor: Colors.white,
  SettingKeys.mirrorFrame: "default.png",
  SettingKeys.mirrorRefresh: false,
  SettingKeys.quitOnSave: true,
};

String defaultMirrorLayout = "";
