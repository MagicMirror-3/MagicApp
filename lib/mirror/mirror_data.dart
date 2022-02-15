import 'dart:convert';

enum ModulePosition {
  top_bar,
  top_left,
  top_center,
  top_right,
  upper_third,
  middle_center,
  lower_third,
  bottom_left,
  bottom_center,
  bottom_right,
  bottom_bar,
  fullscreen_above,
  fullscreen_below,
  from_menu
}

extension ParseToString on ModulePosition {
  String toShortString() {
    return toString().split(".").last;
  }
}

class Module {
  Module(
      {required this.name,
      required this.position,
      this.description,
      this.image = "no_image.png",
      this.config}) {
    originalPosition = position;
  }

  final String name;
  ModulePosition position;
  final String? description;
  final String image;
  Map<String, String>? config;
  late ModulePosition originalPosition;
}

class MirrorLayout {
  Map<ModulePosition, Module> modules = {};

  /// The String has to follow this format: https://docs.magicmirror.builders/modules/configuration.html#example
  static MirrorLayout fromString(String string) {
    List<dynamic> moduleList = jsonDecode(string);

    MirrorLayout layout = MirrorLayout();
    for (Map<String, dynamic> moduleEntry in moduleList) {
      String moduleName = moduleEntry["module"];
      ModulePosition position = ModulePosition.values
          .firstWhere((pos) => pos.toShortString() == moduleEntry["position"]);

      // TODO: support config
      layout.changeModulePosition(
        Module(
          name: moduleName,
          position: position,
        ),
        position,
      );
    }

    return layout;
  }

  @override
  String toString() {
    List<Map<String, dynamic>> moduleList = [];

    for (MapEntry<ModulePosition, Module> entry in modules.entries) {
      Module m = entry.value;

      Map<String, dynamic> moduleMap = {
        "module": m.name,
        "position": entry.key.toShortString(),
      };

      if (m.config != null) {
        moduleMap.putIfAbsent("config", () => m.config);
      }
      moduleList.add(moduleMap);
    }

    return jsonEncode(moduleList);
  }

  void changeModulePosition(Module newModule, ModulePosition newPosition) {
    // print("Moving module '${newModule.name}' to '$newPosition'");
    modules.update(
      newPosition,
      (oldModule) {
        // print("Previous Module was '${oldModule.name}'");
        if (newModule.position != ModulePosition.from_menu) {
          modules.update(
            newModule.position,
            (_) => oldModule,
            ifAbsent: () => oldModule,
          );

          oldModule.position = newModule.position;
        }

        return newModule;
      },
      ifAbsent: () {
        // print("No previous module!");

        modules.remove(newModule.position);
        return newModule;
      },
    );

    // Update the position of the module internally
    newModule.position = newPosition;
  }
}
