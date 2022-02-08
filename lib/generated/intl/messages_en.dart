// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(name) => "Hello ${name}!";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "appName": MessageLookupByLibrary.simpleMessage("Magic App"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "defaultString": MessageLookupByLibrary.simpleMessage("Default"),
        "greetings": m0,
        "magicMirror": MessageLookupByLibrary.simpleMessage("MagicMirror"),
        "profile": MessageLookupByLibrary.simpleMessage("Profile"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "settings_alternativeAppearance":
            MessageLookupByLibrary.simpleMessage("Alternative Appearance"),
        "settings_appAppearance":
            MessageLookupByLibrary.simpleMessage("App Appearance"),
        "settings_brickWall":
            MessageLookupByLibrary.simpleMessage("Brick Wall"),
        "settings_concrete": MessageLookupByLibrary.simpleMessage("Concrete"),
        "settings_concrete2":
            MessageLookupByLibrary.simpleMessage("Concrete 2"),
        "settings_concrete3":
            MessageLookupByLibrary.simpleMessage("Concrete 3"),
        "settings_darkBrickWall":
            MessageLookupByLibrary.simpleMessage("Dark Brick Wall"),
        "settings_darkBrickWall2":
            MessageLookupByLibrary.simpleMessage("Dark Brick Wall 2"),
        "settings_darkMode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
        "settings_darkWall": MessageLookupByLibrary.simpleMessage("Dark Wall"),
        "settings_langDe": MessageLookupByLibrary.simpleMessage("German"),
        "settings_langEn": MessageLookupByLibrary.simpleMessage("English"),
        "settings_language": MessageLookupByLibrary.simpleMessage("Language"),
        "settings_mirrorAppearance":
            MessageLookupByLibrary.simpleMessage("Mirror Appearance"),
        "settings_mirrorBorder":
            MessageLookupByLibrary.simpleMessage("Mirror Border"),
        "settings_redox": MessageLookupByLibrary.simpleMessage("Redox"),
        "settings_soft": MessageLookupByLibrary.simpleMessage("Soft"),
        "settings_wallColor":
            MessageLookupByLibrary.simpleMessage("Wall Color"),
        "settings_wallPattern":
            MessageLookupByLibrary.simpleMessage("Wall Pattern"),
        "settings_whiteWall": MessageLookupByLibrary.simpleMessage("White Wall")
      };
}
