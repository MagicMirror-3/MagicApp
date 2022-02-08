import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

// ---------- [General Themes] ---------- //
const darkCupertinoTheme = CupertinoThemeData(
  textTheme: CupertinoTextThemeData(
    textStyle: TextStyle(
      color: Colors.white,
      fontSize: 16,
    ),
    pickerTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
    ),
  ),
  scaffoldBackgroundColor: Colors.black,
  barBackgroundColor: Colors.black,
);

const lightCupertinoTheme = CupertinoThemeData(
  textTheme: CupertinoTextThemeData(
    textStyle: TextStyle(color: Colors.black),
    pickerTextStyle: TextStyle(color: Colors.black),
  ),
  scaffoldBackgroundColor: Colors.white,
  barBackgroundColor: Colors.white,
);

// ---------- [Settings Themes] ---------- //
// somehow this is the theme used for dark mode
const lightCupertinoSettingsTheme = SettingsThemeData(
  trailingTextColor: Colors.grey,
  settingsListBackground: Colors.black,
  settingsSectionBackground: Colors.white10,
  dividerColor: Colors.white12,
  tileHighlightColor: Colors.white24,
  titleTextColor: Colors.white,
  leadingIconsColor: Colors.white70,
  tileDescriptionTextColor: Colors.white10,
  settingsTileTextColor: Colors.white,
  inactiveTitleColor: Colors.red,
  inactiveSubtitleColor: Colors.red,
);

const darkCupertinoSettingsTheme = SettingsThemeData(
  trailingTextColor: Colors.grey,
  settingsListBackground: Colors.black,
  settingsSectionBackground: Colors.white10,
  dividerColor: Colors.white12,
  tileHighlightColor: Colors.white24,
  titleTextColor: Colors.white,
  leadingIconsColor: Colors.white70,
  tileDescriptionTextColor: Colors.white10,
  settingsTileTextColor: Colors.white,
  inactiveTitleColor: Colors.red,
  inactiveSubtitleColor: Colors.red,
);

SettingsThemeData lightMaterialSettingsTheme = SettingsThemeData(
  trailingTextColor: ThemeData.light().primaryColorDark,
  settingsListBackground: ThemeData.light().scaffoldBackgroundColor,
  settingsSectionBackground: ThemeData.light().scaffoldBackgroundColor,
  dividerColor: ThemeData.light().backgroundColor,
  tileHighlightColor: ThemeData.light().highlightColor,
  titleTextColor: ThemeData.light().primaryColorDark,
  leadingIconsColor: ThemeData.light().iconTheme.color,
  tileDescriptionTextColor: ThemeData.light().hintColor,
  settingsTileTextColor: ThemeData.light().textTheme.bodyText1?.color,
  inactiveTitleColor: Colors.red,
  inactiveSubtitleColor: Colors.red,
);

SettingsThemeData darkMaterialSettingsTheme = SettingsThemeData(
  trailingTextColor: ThemeData.dark().primaryColorLight,
  settingsListBackground: ThemeData.dark().scaffoldBackgroundColor,
  settingsSectionBackground: ThemeData.dark().scaffoldBackgroundColor,
  dividerColor: ThemeData.dark().backgroundColor,
  tileHighlightColor: ThemeData.dark().highlightColor,
  titleTextColor: ThemeData.dark().primaryColorLight,
  leadingIconsColor: ThemeData.dark().iconTheme.color,
  tileDescriptionTextColor: ThemeData.dark().hintColor,
  settingsTileTextColor: ThemeData.dark().textTheme.bodyText1?.color,
  inactiveTitleColor: Colors.red,
  inactiveSubtitleColor: Colors.red,
);
