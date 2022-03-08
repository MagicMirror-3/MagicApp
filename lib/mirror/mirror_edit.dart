import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/generated/l10n.dart';
import 'package:magic_app/mirror/mirror_container.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/util/shared_preferences_handler.dart';
import 'package:magic_app/util/text_types.dart';
import 'package:magic_app/util/themes.dart';
import 'package:settings_ui/settings_ui.dart';

import '../util/settings_widgets.dart';
import 'mirror_data.dart';
import 'mirror_view.dart';

/// This widget support the configuration of the [MirrorLayout] and [Module.config].
///
/// If a [selectedModule] is provided, the configuration options ([_ModuleConfiguration]) are shown,
/// if [selectedModule] is [null], the [_ModuleCatalog] is shown on the right hand side.
class MirrorEdit extends StatefulWidget {
  const MirrorEdit({this.selectedModule, Key? key}) : super(key: key);

  /// The currently selectedModule.
  ///
  /// [null] means that no module is selected
  final Module? selectedModule;

  @override
  _MirrorEditState createState() => _MirrorEditState();
}

class _MirrorEditState extends State<MirrorEdit> {
  Module? selectedModule;

  /// A list of modules containing every available module
  List<Module> moduleCatalog = [
    Module(name: "dummy_module_1", position: ModulePosition.from_menu),
    Module(name: "dummy_module_2", position: ModulePosition.from_menu),
    Module(name: "dummy_module_3", position: ModulePosition.from_menu),
    Module(name: "dummy_module_4", position: ModulePosition.from_menu),
    Module(name: "dummy_module_5", position: ModulePosition.from_menu),
  ];

  /// A [GlobalKey] to retrieve the state of the [MirrorView]
  final GlobalKey<MirrorViewState> mirrorViewKey =
      GlobalKey(debugLabel: "MirrorView");

  /// Triggers a refresh of the Flutter widget cache
  bool keyUpdateFlag = false;

  @override
  void initState() {
    super.initState();

    setSelectedModule(widget.selectedModule);

    // Force landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Go fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void deactivate() {
    // Force portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Deactivate fullscreen
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    ).then((_) => super.deactivate());
  }

  /// Sets [selectedModule] to the given [module].
  ///
  /// This triggers a rebuild of the widget.
  void setSelectedModule(Module? module) {
    // Only rebuild, if the module actually changed
    if (module != selectedModule) {
      setState(() {
        mirrorViewKey.currentState?.selectedModule = module;
        selectedModule = module;
        keyUpdateFlag = !keyUpdateFlag;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // The layout of the mirror with the frame and wall
    MirrorContainer mirrorContainer = MirrorContainer(
      mirrorSize: 80,
      enableClick: false,
      displayLoading: false,
      selectedModule: selectedModule,
      onModuleChanged: setSelectedModule,
      mirrorViewKey: mirrorViewKey,
    );

    // The icons displayed in the top right corner to save the layout or quit the editor
    // TODO: autoSaveOnExit -> No checkmark needed
    List<PlatformIconButton> controlIcons = [
      // This checkmark saves the layout
      PlatformIconButton(
          icon: Icon(
            PlatformIcons(context).checkMarkCircledSolid,
            color: Colors.green,
            semanticLabel: S.of(context).saveChanges,
          ),
          padding: const EdgeInsets.all(0),
          onPressed: () {
            SharedPreferencesHandler.saveValue(
              SettingKeys.mirrorLayout,
              mirrorViewKey.currentState?.layout,
            );

            // Automatically quit if the user wants it to
            if (SharedPreferencesHandler.getValue(SettingKeys.quitOnSave)) {
              Navigator.pop(context);
            }
          }),
      // This checkmark exists the layout editor without saving
      PlatformIconButton(
        icon: Icon(
          PlatformIcons(context).clearThickCircled,
          color: Colors.red,
          semanticLabel: S.of(context).cancel,
        ),
        padding: const EdgeInsets.all(0),
        // TODO: Prompt unsaved changes
        onPressed: () => Navigator.pop(context),
      ),
    ];

    // The key of the second widget (right hand side of the layout) has to contain
    // the flag to always update if wanted
    Key secondWidgetKey = Key("MirrorEdit:$keyUpdateFlag");

    // The layout of the entire editor
    Row finalWidget = Row(
      children: [
        // Container on the left
        mirrorContainer,
        // Other widget on the right with button overlay
        Flexible(
          child: selectedModule == null
              ? _ModuleCatalog(
                  key: secondWidgetKey,
                  modules: moduleCatalog,
                  actions: controlIcons,
                )
              : _ModuleConfiguration(
                  actions: controlIcons,
                  key: secondWidgetKey,
                  selectedModule: selectedModule!,
                  saveCallback: (config) => mirrorViewKey.currentState!.layout
                      .saveModuleConfiguration(
                    selectedModule!.position,
                    config,
                  ),
                  cancelCallback: () => setSelectedModule(null),
                ),
        ),
      ],
    );

    // Wrap the entire layout in a transparent material widget to fix issues with
    // icons on Android
    return isMaterial(context)
        ? Material(
            child: finalWidget,
            borderOnForeground: false,
            type: MaterialType.transparency,
          )
        : finalWidget;
  }
}

/// Displays a list of Modules to drag into the layout
class _ModuleCatalog extends StatelessWidget {
  const _ModuleCatalog({Key? key, required this.modules, required this.actions})
      : super(key: key);

  /// Every available module
  final List<Module> modules;

  /// The actions in the upper right corner (save / exit)
  final List<PlatformIconButton> actions;

  @override
  Widget build(BuildContext context) {
    // Use a sliver scroll container
    return CustomScrollView(
      slivers: [
        // The app bar with a title and the given action icons
        SliverAppBar(
          title: Text(S.of(context).module_catalog),
          floating: true,
          // Removes the leading "<" icon the close the layout
          automaticallyImplyLeading: false,
          backgroundColor: isMaterial(context)
              ? ThemeData.dark().appBarTheme.backgroundColor
              : darkCupertinoTheme.barBackgroundColor,
          actions: actions,
        ),
        SliverList(
          delegate: SliverChildListDelegate.fixed(
            modules.map((module) => DefaultPlatformText(module.name)).toList(),
          ),
        ),
      ],
    );
  }
}

/// Supports the configuration of a module by providing a settings-like screen
class _ModuleConfiguration extends StatefulWidget {
  const _ModuleConfiguration(
      {Key? key,
      required this.selectedModule,
      required this.actions,
      required this.saveCallback,
      required this.cancelCallback})
      : super(key: key);

  /// The module to display the [Module.config] of
  final Module selectedModule;

  /// The actions in the upper right corner (save / exit)
  final List<PlatformIconButton> actions;

  /// The function to call if the user saves the changes made to the configuration
  final Function(Map<String, dynamic>) saveCallback;

  /// The function to call if the user cancels the changes
  final Function() cancelCallback;

  @override
  State<StatefulWidget> createState() => _ModuleConfigurationState();
}

class _ModuleConfigurationState extends State<_ModuleConfiguration> {
  /// Store the config in a local variable to be able to reset the changes
  late Map<String, dynamic> moduleConfiguration =
      Map.from(widget.selectedModule.config ?? {});

  /// Needed to validate all inputs in the form
  final GlobalKey<FormState> formKey = GlobalKey(debugLabel: "FormKey");

  /// Triggers a refresh of the Flutter widget cache
  bool keyUpdateFlag = false;

  /// Saves a change in the mirror configuration to the local configuration map.
  ///
  /// The module configuration can have multiple layers of maps and lists.
  /// [key] is the top-level key of the config entry
  ///
  /// [value] is the new value of the config entry, while [fullValue] contains all values
  /// of the top-level [key].
  ///
  /// If the configuration option is a list or map, [subKey] and [listIndex] are needed to save
  /// the correct value of the item.
  void saveConfigurationChange(String key, dynamic value, dynamic fullValue,
      String? subKey, int? listIndex) {
    if (fullValue == null) {
      setState(() {
        moduleConfiguration[key] = value;
      });
    } else if (subKey != null) {
      // print("Saving subKey $subKey in $fullValue. Index: $listIndex");

      if (listIndex != null) {
        fullValue[listIndex][subKey] = value;
      } else {
        fullValue[subKey] = value;
      }
      setState(() {
        moduleConfiguration[key] = fullValue;
      });
    } else {
      print("cant save this: $key, $value, $fullValue, $subKey");
    }
  }

  SettingsTile createSettingsTile(
      String key, dynamic displayValue, BuildContext context,
      {dynamic fullValue, String? subKey, int? listIndex}) {
    if (displayValue == null) {
      throw Exception("Display value can not be null!");
    }

    if (fullValue != null && subKey == null ||
        fullValue == null && subKey != null) {
      throw Exception(
          "Both fullValue and subKey have to be specified if one of them is!");
    }

    Key widgetKey = Key("${widget.selectedModule.name}:$key:$keyUpdateFlag");
    if (displayValue is String) {
      return SettingsTile(
        title: Text(subKey ?? key),
        trailing: SizedBox(
          // Make this input field the size of a quarter of the screen
          // TODO: Fix keyboard overlaying input box -> Maybe insert a new element into the widget tree
          width: MediaQuery.of(context).size.width / 4,
          child: PlatformTextFormField(
            key: widgetKey,
            initialValue: displayValue,
            hintText: displayValue,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).fillOutField;
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.always,
            onChanged: (value) => saveConfigurationChange(
              key,
              value,
              fullValue,
              subKey,
              listIndex,
            ),
          ),
        ),
      );
    } else if (displayValue is bool) {
      return SettingsTile.switchTile(
        title: Text(subKey ?? key),
        key: widgetKey,
        initialValue: displayValue,
        onToggle: (value) =>
            saveConfigurationChange(key, value, fullValue, subKey, listIndex),
      );
    } else {
      return SettingsTile(title: Text(key));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget = Center(
      child: DefaultPlatformText(S.of(context).noModuleConfiguration),
    );

    if (moduleConfiguration.isNotEmpty) {
      List<SettingsSection> sections = [];
      List<AbstractSettingsTile> generalTiles = [];

      for (MapEntry<String, dynamic> entry in moduleConfiguration.entries) {
        String key = entry.key;
        var value = entry.value;

        List<AbstractSettingsTile> tiles = [];

        if (value is List) {
          dynamic fullValue = value;
          int listIndex = 0;

          for (Map<String, dynamic> listItem in value) {
            for (MapEntry<String, dynamic> entry in listItem.entries) {
              tiles.add(createSettingsTile(
                key,
                entry.value,
                context,
                fullValue: fullValue,
                subKey: entry.key,
                listIndex: listIndex,
              ));
            }

            if (fullValue.length > 1) {
              tiles.add(SettingsTile(
                title: Text(S.of(context).removeListItem),
                leading: Icon(PlatformIcons(context).removeCircledOutline,
                    color: Colors.red),
                description: const Text(
                  "",
                  style: TextStyle(
                    fontSize: 1,
                  ),
                ),
                onPressed: (_) => setState(() {
                  value.remove(listItem);

                  // Set flag to refresh widgets
                  keyUpdateFlag = !keyUpdateFlag;
                }),
              ));
            }
            listIndex++;
          }

          // Always give the user the possibility to add an item to the list
          tiles.add(SettingsTile(
            title: Text(S.of(context).addListItem),
            leading: Icon(PlatformIcons(context).addCircledOutline,
                color: Colors.green),
            onPressed: (_) => setState(() {
              Map<String, dynamic> mapClone = Map.from(value[value.length - 1]);
              value.add(mapClone);
            }),
          ));
        } else if (value is Map) {
          dynamic fullValue = value;
          for (MapEntry<String, dynamic> entry in fullValue.entries) {
            tiles.add(createSettingsTile(
              key,
              entry.value,
              context,
              fullValue: fullValue,
              subKey: entry.key,
            ));
          }
        } else {
          generalTiles.add(createSettingsTile(key, value, context));
        }

        if (tiles.isNotEmpty) {
          sections.add(SettingsSection(title: Text(key), tiles: tiles));
        }
      }

      if (generalTiles.isNotEmpty) {
        sections.insert(
          0,
          SettingsSection(
            title: Text(S.of(context).settings_general),
            tiles: generalTiles,
          ),
        );
      }

      if (sections.isNotEmpty) {
        bodyWidget = MagicSettingsList(sections: sections);
      }
    }

    FormState? formState = formKey.currentState;

    return Column(
      children: [
        PlatformAppBar(
          title: Text(S.of(context).module_configuration),
          automaticallyImplyLeading: false,
          trailingActions: widget.actions,
        ),
        Flexible(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.always,
            child: bodyWidget,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isMaterial(context)
                ? ThemeData.dark().scaffoldBackgroundColor
                : darkCupertinoTheme.barBackgroundColor,
            border: const Border(
              top: BorderSide(color: Colors.white12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              PlatformElevatedButton(
                child: Text(S.of(context).saveChanges),
                color: Colors.green,
                onPressed: formState != null && formState.validate() ||
                        formState == null
                    ? () => widget.saveCallback(moduleConfiguration)
                    : null,
                padding: const EdgeInsets.all(8),
              ),
              PlatformElevatedButton(
                child: Text(S.of(context).cancel),
                color: Colors.red,
                onPressed: () => widget.cancelCallback(),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
