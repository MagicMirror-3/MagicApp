import 'package:flutter/services.dart';
import 'package:magic_app/mirror/module.dart';
import 'package:magic_app/util/communication_handler.dart';

import '../util/utility.dart';

/// Contains the current layout and every available module
class MirrorLayoutHandler {
  // Make constructor private
  MirrorLayoutHandler._();

  /// The layout of the mirror
  static late MirrorLayout _layout;

  /// The layout of the current user
  /// Make sure [init] is called before. Otherwise an [AssertionError] is thrown.
  static MirrorLayout get layout {
    assert(_initialized);

    return _layout;
  }

  /// Every available additional module
  static late List<Module> moduleCatalog;

  /// Needed for the temporary moving of modules on hover
  static Module? _tempMovedModule;

  /// Whether the layout and module catalog were loaded
  static bool _initialized = false;

  /// True, if layout and catalog are present
  static bool get isReady => _initialized;

  /// Initialize layout and catalog
  ///
  /// Returns true, if the layout was retrieved and this handler is ready to use
  static Future<bool> init() async {
    await refresh();

    return _initialized;
  }

  /// Refresh catalog and layout
  static Future refresh() async {
    await _refreshLayout();
    await _refreshCatalog();
  }

  /// Refresh the mirror layout
  static Future _refreshLayout() async {
    MirrorLayout? tempLayout = await CommunicationHandler.getMirrorLayout();

    if (tempLayout != null) {
      _layout = tempLayout;
    }

    _initialized = tempLayout != null;
  }

  /// Load the default layout from the [default_layout.json] file
  static void loadDefaultLayout() async {
    _layout = MirrorLayout.fromString(
      await rootBundle.loadString("assets/default_layout.json"),
    );

    saveLayout();
  }

  /// Refresh the module catalog
  static Future _refreshCatalog() async {
    moduleCatalog = await CommunicationHandler.getModules();
  }

  /// Save the current layout to the preferences and backend
  static void saveLayout() {
    CommunicationHandler.updateLayout(_layout);
  }

  /// Permanently moves [module] to the given [position] in the layout.
  static void moveModule(Module module, ModulePosition position) {
    assert(_initialized);

    // print("Moving module '${module.name}' to '$position'");

    undoTemporaryMove();

    Module? currentModule = _layout.getModule(position);
    // If there already is a module at this position, change the originalPosition to the originalPosition
    // of the moved module
    if (currentModule != null) {
      // print(
      //     "Moving current module '${currentModule.name}' to '${module.originalPosition}'");

      // Save original position
      currentModule.originalPosition = module.originalPosition;

      // Add the current module to the catalog if the new module is from the menu
      if (module.originalPosition == ModulePosition.menu) {
        moduleCatalog.remove(module);
        moduleCatalog.add(currentModule);
      }
    }

    // Module is removed from layout
    if (position == ModulePosition.menu) {
      _layout.removeModule(module);
      moduleCatalog.add(module);
    } else {
      // Move the modules in the layout
      // The 'position' field will be changed by this method
      _layout.setModulePosition(module, position);
    }

    // Save new position as original position
    module.originalPosition = position;
  }

  /// Temporarily move a module to the given [position]
  static void temporarilyMoveModule(Module module, ModulePosition position) {
    assert(_initialized);

    // Undo the last move
    undoTemporaryMove();

    // Save the module at the position
    _tempMovedModule = _layout.modules[position];

    // Check if the modules are actually different
    if (module.name != _tempMovedModule?.name) {
      // Swap the modules
      _layout.setModulePosition(module, position);

      // Move the old one back to the original position of the new one
      if (_tempMovedModule != null) {
        _layout.setModulePosition(
          _tempMovedModule!,
          module.originalPosition,
        );
      }
    }
  }

  /// Undoes the last temporary move my moving the module back to its position
  static void undoTemporaryMove() {
    assert(_initialized);

    if (_tempMovedModule != null) {
      // Move the module back to it's original position
      _layout.setModulePosition(
        _tempMovedModule!,
        _tempMovedModule!.originalPosition,
      );

      _tempMovedModule = null;
    }
  }

  /// Remove a module from the catalog because it was added to the layout
  static void removeFromCatalog(Module module) {
    moduleCatalog.remove(module);
  }
}

/// Represents the layout of the modules on the mirror
class MirrorLayout {
  /// Mapping each module to a position on the mirror
  Map<ModulePosition, Module> modules = {};

  Module? getModule(ModulePosition position) => modules[position];

  /// Converts a given [string] to a layout representation.
  ///
  /// The String has to follow this format: <https://docs.magicmirror.builders/modules/configuration.html#example>
  static MirrorLayout fromString(String string) {
    MirrorLayout layout = MirrorLayout();
    // Add every module to the layout
    for (Module module in modulesFromJSON(string)) {
      if (module.originalPosition != ModulePosition.menu) {
        layout.setModulePosition(
          module,
          module.originalPosition,
        );
      }
    }

    return layout;
  }

  /// Converts the layout back to the string format needed for the MagicMirror framework.
  @override
  String toString() {
    return modulesToJSON(modules.values.toList());
  }

  /// Updates the position of the [module] on the layout to [position].
  ///
  /// This method also handles the switching of modules, if [position] is already
  /// occupied by another method.
  void setModulePosition(Module module, ModulePosition position) {
    // print("Setting module '${module.name}' to '$position'");
    modules.update(
      position,
      (oldModule) {
        // print("Previous Module was '${oldModule.name}'");
        // Move the old module to the original position of the new module
        modules.update(
          module.position,
          (_) => oldModule,
          ifAbsent: () => oldModule,
        );

        oldModule.position = module.position;

        return module;
      },
      ifAbsent: () {
        // print("No previous module!");

        modules.remove(module.position);
        return module;
      },
    );

    // Update the position of the module internally
    module.position = position;
  }

  /// Save the [newConfiguration] of the [Module] at the position [modulePosition].
  ///
  /// This method is typically called after the configuration of the module changed
  void saveModuleConfiguration(
      ModulePosition modulePosition, Map<String, dynamic> newConfiguration) {
    // print("configuration changed to $newConfiguration");
    modules[modulePosition]?.config = newConfiguration;
  }

  /// Removes a module from the layout -> Probably to put it into the catalog
  void removeModule(Module module) {
    modules.remove(module.position);
  }
}
