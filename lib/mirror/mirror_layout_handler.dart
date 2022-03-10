import 'package:magic_app/mirror/module.dart';
import 'package:magic_app/util/communication_handler.dart';

import '../settings/constants.dart';
import '../settings/shared_preferences_handler.dart';
import '../util/utility.dart';

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
      SharedPreferencesHandler.saveValue(SettingKeys.mirrorLayout, _layout);
    }

    _initialized = tempLayout != null;
  }

  /// Load the default layout from the [default_layout.json] file
  static void loadDefaultLayout() async {
    _layout = (defaultValues[SettingKeys.mirrorLayout]) as MirrorLayout;

    saveLayout();
  }

  /// Refresh the module catalog
  static Future _refreshCatalog() async {
    moduleCatalog = await CommunicationHandler.getModules();
  }

  /// Save the current layout to the preferences and backend
  static void saveLayout() {
    SharedPreferencesHandler.saveValue(SettingKeys.mirrorLayout, _layout);
    CommunicationHandler.updateLayout(_layout);
  }

  /// Permanently moves [module] to the given [position] in the layout.
  static void moveModule(Module module, ModulePosition position) {
    assert(_initialized);

    // print("Moving module '${module.name}' to '$position'");

    undoTemporaryMove();

    Module? currentModule = _layout.getModule(position);
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

    if (position == ModulePosition.menu) {
      _layout.removeModule(module);
      moduleCatalog.add(module);
    } else {
      // Move the modules in the layout
      // The 'position' field will be changed by this method
      _layout.changeModulePosition(module, position);
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
      _layout.changeModulePosition(module, position);

      // Move the old one back to the original position of the new one
      if (_tempMovedModule != null) {
        _layout.changeModulePosition(
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
      _layout.changeModulePosition(
        _tempMovedModule!,
        _tempMovedModule!.originalPosition,
      );

      _tempMovedModule = null;
    } else {
      // print("No temporary move to undo!");
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
        if (newModule.position != ModulePosition.menu) {
          modules.update(
            newModule.position,
            (_) => oldModule,
            ifAbsent: () => oldModule,
          );
        }

        oldModule.position = newModule.position;

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

  /// Removes a module from the layout -> Probably to put it into the catalog
  void removeModule(Module module) {
    modules.remove(module.position);
  }
}
