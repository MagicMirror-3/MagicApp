import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/generated/l10n.dart';

import '../mirror/module.dart';

/// Show a cupertino picker with the given [items].
///
/// [onIndexSelected] will be called once the selected index changes or the picker
/// was closed.
showCupertinoDropdownPopup({
  required BuildContext context,
  required List<Widget> items,
  required ValueChanged<int> onIndexSelected,
  int initialItem = 0,
}) {
  int tempIndex = initialItem;

  showCupertinoModalPopup(
    context: context,
    builder: (context) => SizedBox(
      height: 200,
      child: CupertinoPicker(
        itemExtent: 24,
        onSelectedItemChanged: (index) {
          tempIndex = index;
        },
        backgroundColor: Colors.black,
        scrollController: FixedExtentScrollController(initialItem: initialItem),
        children: items,
      ),
    ),
    semanticsDismissible: true,
  ).then((_) => onIndexSelected(tempIndex));
}

showYesNoPrompt(
  BuildContext context, {
  required String title,
  String? description,
  String? confirmationText,
  String? cancelText,
  Function()? successCallback,
  Function()? cancelCallback,
}) {
  description ??= S.of(context).prompt_sure;
  confirmationText ??= S.of(context).yes;
  cancelText ??= S.of(context).cancel;

  showPlatformDialog(
    context: context,
    builder: (_) => PlatformAlertDialog(
      title: Text(title),
      content: Text(description!),
      actions: [
        PlatformDialogAction(
          child: Text(cancelText!),
          onPressed: () {
            Navigator.pop(context);

            if (cancelCallback != null) {
              cancelCallback();
            }
          },
        ),
        PlatformDialogAction(
          child: Text(confirmationText!),
          onPressed: () {
            if (successCallback != null) {
              successCallback();
            }
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

/// Loads a list of modules from a given String in JSON format.
List<Module> modulesFromJSON(String jsonString) {
  List<Module> modules = [];

  // decode the string
  dynamic stringJSON = jsonDecode(jsonString);

  // The most outer structure should be a list
  if (stringJSON is List) {
    for (dynamic listEntry in stringJSON) {
      // Entry has to be a Map and contain at least the key 'module'
      if (listEntry is Map && listEntry.containsKey("module")) {
        String moduleName = listEntry["module"];

        // Try getting the position in the dict. Defaults to ModulePosition.from_menu
        ModulePosition modulePosition = ModulePosition.values.firstWhere(
          (element) => element.name == listEntry["position"],
          orElse: () => ModulePosition.menu,
        );

        // Get the config
        Map<String, dynamic> moduleConfig = listEntry["config"] ?? {};

        // Save the module
        modules.add(
          Module(
            name: moduleName,
            position: modulePosition,
            header: listEntry["header"],
            config: moduleConfig,
          ),
        );
      } else {
        print("WTF is this entry: $listEntry");
      }
    }
  } else {
    print("String contains no list ffs");
  }

  return modules;
}

/// Converts a list of modules to a JSON string
String modulesToJSON(List<Module> modules) {
  // Go over every module and create a map representation of it
  return jsonEncode(
    modules
        .map(
          (m) => {
            "module": m.name,
            "position": m.position.name,
            "config": m.config ?? {},
          },
        )
        .toList(),
  );
}

/// Represents a user of the mirror
class MagicUser {
  const MagicUser({
    this.id = -1,
    this.firstName = "",
    this.lastName = "",
  });

  /// Parses user information from a given map.
  ///
  /// The map has to contain the keys `"id", "firstName", "lastName", "password"`
  MagicUser.fromJSON(Map<String, dynamic> userMap)
      : id = userMap["id"],
        firstName = userMap["firstName"],
        lastName = userMap["lastName"];

  /// The unique identifier of the user
  final int id;

  /// The first name of the user
  final String firstName;

  /// The last name of the user
  final String lastName;

  /// Whether the user is not the default user.
  ///
  /// The default user has no name and the id 0
  bool get isRealUser => id != 0 && !(firstName.isEmpty && lastName.isEmpty);

  /// A combination of first and last name
  String get name => "$firstName $lastName";

  @override
  String toString() {
    return jsonEncode({
      "id": id,
      "firstName": firstName,
      "lastName": lastName,
    });
  }
}
