// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Magic App`
  String get appName {
    return Intl.message(
      'Magic App',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `MagicMirror`
  String get magicMirror {
    return Intl.message(
      'MagicMirror',
      name: 'magicMirror',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Save changes`
  String get saveChanges {
    return Intl.message(
      'Save changes',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Delete User`
  String get deleteUser {
    return Intl.message(
      'Delete User',
      name: 'deleteUser',
      desc: '',
      args: [],
    );
  }

  /// `Default`
  String get defaultString {
    return Intl.message(
      'Default',
      name: 'defaultString',
      desc: '',
      args: [],
    );
  }

  /// `Please fill out this field`
  String get fillOutField {
    return Intl.message(
      'Please fill out this field',
      name: 'fillOutField',
      desc: '',
      args: [],
    );
  }

  /// `Connect a mirror`
  String get connect_mirror {
    return Intl.message(
      'Connect a mirror',
      name: 'connect_mirror',
      desc: '',
      args: [],
    );
  }

  /// `Pull down to start searching for MagicMirrors on your local network`
  String get local_network_refresh {
    return Intl.message(
      'Pull down to start searching for MagicMirrors on your local network',
      name: 'local_network_refresh',
      desc: '',
      args: [],
    );
  }

  /// `No MagicMirror found! Please make sure it is turned on and connected to your network!`
  String get no_mirror_found {
    return Intl.message(
      'No MagicMirror found! Please make sure it is turned on and connected to your network!',
      name: 'no_mirror_found',
      desc: '',
      args: [],
    );
  }

  /// `Select a user`
  String get select_user {
    return Intl.message(
      'Select a user',
      name: 'select_user',
      desc: '',
      args: [],
    );
  }

  /// `Select a user or create a new one`
  String get select_user_or_create {
    return Intl.message(
      'Select a user or create a new one',
      name: 'select_user_or_create',
      desc: '',
      args: [],
    );
  }

  /// `Your profile`
  String get your_profile {
    return Intl.message(
      'Your profile',
      name: 'your_profile',
      desc: '',
      args: [],
    );
  }

  /// `First name`
  String get first_name {
    return Intl.message(
      'First name',
      name: 'first_name',
      desc: '',
      args: [],
    );
  }

  /// `Enter your first name`
  String get first_name_hint {
    return Intl.message(
      'Enter your first name',
      name: 'first_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Last name`
  String get last_name {
    return Intl.message(
      'Last name',
      name: 'last_name',
      desc: '',
      args: [],
    );
  }

  /// `Enter your last name`
  String get last_name_hint {
    return Intl.message(
      'Enter your last name',
      name: 'last_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Hello {name}!`
  String greetings(Object name) {
    return Intl.message(
      'Hello $name!',
      name: 'greetings',
      desc: '',
      args: [name],
    );
  }

  /// `Refreshing layout...`
  String get mirror_refresh {
    return Intl.message(
      'Refreshing layout...',
      name: 'mirror_refresh',
      desc: '',
      args: [],
    );
  }

  /// `Module configuration`
  String get module_configuration {
    return Intl.message(
      'Module configuration',
      name: 'module_configuration',
      desc: '',
      args: [],
    );
  }

  /// `Module catalog`
  String get module_catalog {
    return Intl.message(
      'Module catalog',
      name: 'module_catalog',
      desc: '',
      args: [],
    );
  }

  /// `No configuration available for this module!`
  String get noModuleConfiguration {
    return Intl.message(
      'No configuration available for this module!',
      name: 'noModuleConfiguration',
      desc: '',
      args: [],
    );
  }

  /// `Remove item`
  String get removeListItem {
    return Intl.message(
      'Remove item',
      name: 'removeListItem',
      desc: '',
      args: [],
    );
  }

  /// `Add item`
  String get addListItem {
    return Intl.message(
      'Add item',
      name: 'addListItem',
      desc: '',
      args: [],
    );
  }

  /// `App Appearance`
  String get settings_appAppearance {
    return Intl.message(
      'App Appearance',
      name: 'settings_appAppearance',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get settings_darkMode {
    return Intl.message(
      'Dark Mode',
      name: 'settings_darkMode',
      desc: '',
      args: [],
    );
  }

  /// `Alternative Appearance`
  String get settings_alternativeAppearance {
    return Intl.message(
      'Alternative Appearance',
      name: 'settings_alternativeAppearance',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get settings_language {
    return Intl.message(
      'Language',
      name: 'settings_language',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get settings_langEn {
    return Intl.message(
      'English',
      name: 'settings_langEn',
      desc: '',
      args: [],
    );
  }

  /// `German`
  String get settings_langDe {
    return Intl.message(
      'German',
      name: 'settings_langDe',
      desc: '',
      args: [],
    );
  }

  /// `Mirror Appearance`
  String get settings_mirrorAppearance {
    return Intl.message(
      'Mirror Appearance',
      name: 'settings_mirrorAppearance',
      desc: '',
      args: [],
    );
  }

  /// `Wall Pattern`
  String get settings_wallPattern {
    return Intl.message(
      'Wall Pattern',
      name: 'settings_wallPattern',
      desc: '',
      args: [],
    );
  }

  /// `Brick Wall`
  String get settings_brickWall {
    return Intl.message(
      'Brick Wall',
      name: 'settings_brickWall',
      desc: '',
      args: [],
    );
  }

  /// `Dark Brick Wall`
  String get settings_darkBrickWall {
    return Intl.message(
      'Dark Brick Wall',
      name: 'settings_darkBrickWall',
      desc: '',
      args: [],
    );
  }

  /// `Dark Brick Wall 2`
  String get settings_darkBrickWall2 {
    return Intl.message(
      'Dark Brick Wall 2',
      name: 'settings_darkBrickWall2',
      desc: '',
      args: [],
    );
  }

  /// `Concrete`
  String get settings_concrete {
    return Intl.message(
      'Concrete',
      name: 'settings_concrete',
      desc: '',
      args: [],
    );
  }

  /// `Concrete 2`
  String get settings_concrete2 {
    return Intl.message(
      'Concrete 2',
      name: 'settings_concrete2',
      desc: '',
      args: [],
    );
  }

  /// `Concrete 3`
  String get settings_concrete3 {
    return Intl.message(
      'Concrete 3',
      name: 'settings_concrete3',
      desc: '',
      args: [],
    );
  }

  /// `Redox`
  String get settings_redox {
    return Intl.message(
      'Redox',
      name: 'settings_redox',
      desc: '',
      args: [],
    );
  }

  /// `Soft`
  String get settings_soft {
    return Intl.message(
      'Soft',
      name: 'settings_soft',
      desc: '',
      args: [],
    );
  }

  /// `White Wall`
  String get settings_whiteWall {
    return Intl.message(
      'White Wall',
      name: 'settings_whiteWall',
      desc: '',
      args: [],
    );
  }

  /// `Dark Wall`
  String get settings_darkWall {
    return Intl.message(
      'Dark Wall',
      name: 'settings_darkWall',
      desc: '',
      args: [],
    );
  }

  /// `Wall Color`
  String get settings_wallColor {
    return Intl.message(
      'Wall Color',
      name: 'settings_wallColor',
      desc: '',
      args: [],
    );
  }

  /// `Mirror Border`
  String get settings_mirrorBorder {
    return Intl.message(
      'Mirror Border',
      name: 'settings_mirrorBorder',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get settings_general {
    return Intl.message(
      'General',
      name: 'settings_general',
      desc: '',
      args: [],
    );
  }

  /// `Quit on save`
  String get settings_quitOnSave {
    return Intl.message(
      'Quit on save',
      name: 'settings_quitOnSave',
      desc: '',
      args: [],
    );
  }

  /// `Automatically close the layout editor upon saving`
  String get settings_quitOnSaveDescription {
    return Intl.message(
      'Automatically close the layout editor upon saving',
      name: 'settings_quitOnSaveDescription',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
