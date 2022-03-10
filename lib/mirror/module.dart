// ignore_for_file: constant_identifier_names

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
  menu
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
