import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

/// Contains all text styles
///
/// See <https://material.io/design/typography/the-type-system.html#type-scale> for more information
const magicTextTheme = TextTheme(
  headline1: TextStyle(
    fontFamily: "Roboto",
    fontSize: 96,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.5,
    decoration: TextDecoration.none,
    color: Colors.white,
  ),
  headline2: TextStyle(
    fontFamily: "Roboto",
    fontSize: 60,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
    decoration: TextDecoration.none,
    color: Colors.white,
  ),
  headline3: TextStyle(
    fontFamily: "Roboto",
    fontSize: 48,
    fontWeight: FontWeight.w400,
    decoration: TextDecoration.none,
    color: Colors.white,
  ),
  headline4: TextStyle(
    fontFamily: "Roboto",
    fontSize: 34,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    decoration: TextDecoration.none,
    color: Colors.white,
  ),
  headline5: TextStyle(
    fontFamily: "Roboto",
    fontSize: 24,
    fontWeight: FontWeight.w400,
    decoration: TextDecoration.none,
    color: Colors.white,
  ),
  headline6: TextStyle(
    fontFamily: "Roboto",
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    decoration: TextDecoration.none,
    color: Colors.white,
  ),
  subtitle1: TextStyle(
    fontFamily: "Roboto",
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    decoration: TextDecoration.none,
    color: Colors.white,
  ),
  subtitle2: TextStyle(
    fontFamily: "Roboto",
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    decoration: TextDecoration.none,
    color: Colors.white,
  ),
  bodyText1: TextStyle(
    fontFamily: "Roboto",
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    decoration: TextDecoration.none,
    color: Colors.white,
  ),
  bodyText2: TextStyle(
    fontFamily: "Roboto",
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    decoration: TextDecoration.none,
    color: Colors.white,
  ),
  button: TextStyle(
    fontFamily: "Roboto",
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
    decoration: TextDecoration.none,
    color: Colors.white,
  ),
  caption: TextStyle(
    fontFamily: "Roboto",
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    decoration: TextDecoration.none,
    color: Colors.white,
  ),
  overline: TextStyle(
    fontFamily: "Roboto",
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.5,
    decoration: TextDecoration.none,
    color: Colors.white,
  ),
);

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

final darkMaterialTheme = ThemeData.localize(
  ThemeData.dark(),
  magicTextTheme,
);

const lightCupertinoTheme = CupertinoThemeData(
  textTheme: CupertinoTextThemeData(
    textStyle: TextStyle(color: Colors.black),
    pickerTextStyle: TextStyle(color: Colors.black),
  ),
  scaffoldBackgroundColor: Colors.white,
  barBackgroundColor: Colors.white,
);

final lightMaterialTheme = ThemeData.localize(
  ThemeData.light(),
  magicTextTheme,
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
