// ignore_for_file: constant_identifier_names

import 'package:magic_app/util/utility.dart';

/// Contains every valid position a [Module] can have
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

  /// This position signals that this module is not part of the layout
  from_menu
}

/// Extend the [ModulePosition] enum with a method to convert it to a [String]
extension ParseToString on ModulePosition {
  String toShortString() {
    return toString().split(".").last;
  }
}

/// Represents a module of the mirror
class Module {
  Module(
      {required this.name,
      required this.position,
      this.header,
      this.description,
      this.image = "no_image.png",
      this.config}) {
    originalPosition = position;
  }

  /// The (unique) name of the module
  final String name;

  /// The [ModulePosition] of this module
  ModulePosition position;

  /// An optional header to display on top of this module
  final String? header;

  /// An optional description of this module
  final String? description;

  /// A path to an image of the module in action
  final String image;

  /// The configuration options of the module
  Map<String, dynamic>? config;

  /// Helper [ModulePosition] to correctly move module on the [MirrorEdit] screen
  late ModulePosition originalPosition;

  /// Checks whether [Module] has configuration params
  bool get hasConfig {
    return config != null && config!.isNotEmpty;
  }

  @override
  String toString() {
    return "Module: $name";
  }
}

/// Represents the layout of the modules on the mirror
class MirrorLayout {
  /// Mapping each module to a position on the mirror
  Map<ModulePosition, Module> modules = {};

  /// Converts a given [string] to a layout representation.
  ///
  /// The String has to follow this format: <https://docs.magicmirror.builders/modules/configuration.html#example>
  static MirrorLayout fromString(String string) {
    MirrorLayout layout = MirrorLayout();
    // Add every module to the layout
    for (Module module in modulesFromJSON(string)) {
      layout.changeModulePosition(
        module,
        module.originalPosition,
      );
    }

    return layout;
  }

  /// Converts the layout back to the string format needed for the MagicMirror framework.
  @override
  String toString() {
    return modulesToJSON(modules.values.toList());
  }

  /// Updates the position of the [newModule] on the layout to [newPosition].
  ///
  /// This method also handles the switching of modules, if [newPosition] is already
  /// occupied by another method.
  void changeModulePosition(Module newModule, ModulePosition newPosition) {
    // print("Moving module '${newModule.name}' to '$newPosition'");
    modules.update(
      newPosition,
      (oldModule) {
        // print("Previous Module was '${oldModule.name}'");
        // If the module is not new, move the old module to the original position
        // of the new module
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

  /// Save the [newConfiguration] of the [Module] at the position [modulePosition].
  ///
  /// This method is typically called after the configuration of the module changed
  void saveModuleConfiguration(
      ModulePosition modulePosition, Map<String, dynamic> newConfiguration) {
    print("configuration changed to $newConfiguration");
    modules[modulePosition]?.config = newConfiguration;
  }
}
