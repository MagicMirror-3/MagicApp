import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../mirror/mirror_data.dart';

showCupertinoDropdownPopup(
    {required BuildContext context,
    required List<Widget> items,
    required ValueChanged<int> onIndexSelected,
    int initialItem = 0}) {
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

List<Module> modulesFromJSON(String jsonString) {
  List<Module> modules = [];

  dynamic stringJSON = jsonDecode(jsonString);

  if (stringJSON is List) {
    for (dynamic listEntry in stringJSON) {
      // Entry has to be a Map and contain at least the key 'module'
      if (listEntry is Map && listEntry.containsKey("module")) {
        String moduleName = listEntry["module"];

        // Try getting the position in the dict. Defaults to ModulePosition.from_menu
        ModulePosition modulePosition = ModulePosition.values.firstWhere(
          (element) => element.toShortString() == listEntry["position"],
          orElse: () => ModulePosition.from_menu,
        );

        // Get the config
        Map<String, dynamic> moduleConfig = listEntry["config"] ?? {};

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

String modulesToJSON(List<Module> modules) {
  // Go over every module and create a map representation of it
  return jsonEncode(
    modules
        .map(
          (m) => {
            "module": m.name,
            "position": m.position.toShortString(),
            "config": m.config ?? {},
          },
        )
        .toList(),
  );
}
