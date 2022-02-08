import 'dart:collection';

import 'package:flutter/material.dart';

class SettingChoices {
  static final Map<String, String> wallBackgroundChoices = LinkedHashMap.from({
    "wall.jpg": "Standard",
    "brick-wall.png": "Brick Wall",
    "brick-wall-dark.png": "Dark Brick Wall",
    "dark-brick-wall.png": "Dark Brick Wall 2",
    "concrete-wall.png": "Concrete",
    "concrete-wall-2.png": "Concrete 2",
    "concrete-wall-3.png": "Concrete 3",
    "redox-01.png": "Redox",
    "soft-wallpaper.png": "Soft",
    "white-wall.png": "White wall",
    "dark-wall.png": "Dark wall",
  });

  static final Map<String, String> mirrorBorderChoices = LinkedHashMap.from({
    "default.png": "IKEA Standard",
  });
}

class SettingKeys {
  static const String darkMode = "darkMode";
  static const String alternativeAppearance = "alternativeAppearance";
  static const String wallPattern = "wallPattern";
  static const String wallColor = "wallColor";
  static const String mirrorBorder = "mirrorBorder";
}

const defaultValues = {
  SettingKeys.darkMode: true,
  SettingKeys.alternativeAppearance: false,
  SettingKeys.wallPattern: "wall.jpg",
  SettingKeys.wallColor: Colors.white,
  SettingKeys.mirrorBorder: "default.png"
};
