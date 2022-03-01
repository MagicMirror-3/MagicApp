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

class MirrorEdit extends StatefulWidget {
  const MirrorEdit({this.selectedModule, Key? key}) : super(key: key);

  final Module? selectedModule;

  @override
  _MirrorEditState createState() => _MirrorEditState();
}

class _MirrorEditState extends State<MirrorEdit> {
  Module? selectedModule;

  List<Module> moduleCatalog = [
    Module(name: "dummy_module_1", position: ModulePosition.from_menu),
    Module(name: "dummy_module_2", position: ModulePosition.from_menu),
    Module(name: "dummy_module_3", position: ModulePosition.from_menu),
    Module(name: "dummy_module_4", position: ModulePosition.from_menu),
    Module(name: "dummy_module_5", position: ModulePosition.from_menu),
  ];

  final GlobalKey<MirrorViewState> mirrorViewKey =
      GlobalKey(debugLabel: "MirrorView");

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

  void setSelectedModule(Module? module) {
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
    MirrorContainer mirrorContainer = MirrorContainer(
      mirrorSize: 80,
      enableClick: false,
      displayLoading: false,
      selectedModule: selectedModule,
      onModuleChanged: setSelectedModule,
      mirrorViewKey: mirrorViewKey,
    );

    List<PlatformIconButton> controlIcons = [
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

            if (SharedPreferencesHandler.getValue(SettingKeys.quitOnSave)) {
              Navigator.pop(context);
            }
          }),
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

    Key secondWidgetKey = Key("MirrorEdit:$keyUpdateFlag");

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

    return isMaterial(context)
        ? Material(
            child: finalWidget,
            borderOnForeground: false,
            type: MaterialType.transparency)
        : finalWidget;
  }
}

class _ModuleCatalog extends StatelessWidget {
  const _ModuleCatalog({Key? key, required this.modules, required this.actions})
      : super(key: key);

  final List<Module> modules;
  final List<PlatformIconButton> actions;

  @override
  Widget build(BuildContext context) {
    // TODO: Background color
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(S.of(context).module_catalog),
          floating: true,
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

class _ModuleConfiguration extends StatefulWidget {
  const _ModuleConfiguration(
      {Key? key,
      required this.selectedModule,
      required this.actions,
      required this.saveCallback,
      required this.cancelCallback})
      : super(key: key);

  final Module selectedModule;
  final List<PlatformIconButton> actions;
  final Function(Map<String, dynamic>) saveCallback;
  final Function() cancelCallback;

  @override
  State<StatefulWidget> createState() => _ModuleConfigurationState();
}

class _ModuleConfigurationState extends State<_ModuleConfiguration> {
  late Map<String, dynamic> moduleConfiguration =
      Map.from(widget.selectedModule.config ?? {});
  final GlobalKey<FormState> formKey = GlobalKey(debugLabel: "FormKey");

  bool keyUpdateFlag = false;

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

  SettingsTile createSettingsTile(String key, dynamic displayValue,
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
        trailing: PlatformWidget(
          cupertino: (_, __) => Flexible(
            child: PlatformTextFormField(
              // Use a custom key because this is somehow cached wrong
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
                  key, value, fullValue, subKey, listIndex),
            ),
          ),
          // TODO: Fix this
          material: (_, __) => const Text("Not yet supported"),
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
            title: Text(S.of(context).removeListItem),
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
              fullValue: fullValue,
              subKey: entry.key,
            ));
          }
        } else {
          generalTiles.add(createSettingsTile(key, value));
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
        Flexible(
          fit: FlexFit.tight,
          child: PlatformScaffold(
            appBar: PlatformAppBar(
              title: Text(S.of(context).module_configuration),
              automaticallyImplyLeading: false,
              trailingActions: widget.actions,
            ),
            body: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.always,
              child: bodyWidget,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: isMaterial(context)
                  ? ThemeData.dark().bottomAppBarColor
                  : darkCupertinoTheme.barBackgroundColor),
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
