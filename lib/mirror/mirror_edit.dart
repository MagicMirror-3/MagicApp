import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/generated/l10n.dart';
import 'package:magic_app/mirror/mirror_container.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/util/shared_preferences_handler.dart';
import 'package:magic_app/util/text_types.dart';
import 'package:magic_app/util/themes.dart';

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
  Map<String, dynamic> tempModuleConfig = {};

  List<Module> moduleCatalog = [
    Module(name: "dummy_module_1", position: ModulePosition.from_menu),
    Module(name: "dummy_module_2", position: ModulePosition.from_menu),
    Module(name: "dummy_module_3", position: ModulePosition.from_menu),
    Module(name: "dummy_module_4", position: ModulePosition.from_menu),
    Module(name: "dummy_module_5", position: ModulePosition.from_menu),
  ];

  final GlobalKey<MirrorViewState> mirrorViewKey =
      GlobalKey(debugLabel: "MirrorView");
  final GlobalKey<FormState> formKey = GlobalKey(debugLabel: "FormKey");

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
      mirrorViewKey.currentState?.selectedModule = module;
      setState(() {
        if (module != null) {
          tempModuleConfig = Map.from(module.config ?? {});
        }
        selectedModule = module;
      });
    }
  }

  void saveConfigurationChange(String key, dynamic value) {
    setState(() {
      tempModuleConfig[key] = value;
    });
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

    List<Widget> controlIcons = [
      PlatformIconButton(
          icon: Icon(
            PlatformIcons(context).checkMarkCircledSolid,
            color: Colors.green,
            semanticLabel: "Save changes",
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
          semanticLabel: "Exit configuration",
        ),
        padding: const EdgeInsets.all(0),
        // TODO: Prompt unsaved changes
        onPressed: () => Navigator.pop(context),
      ),
    ];

    List<Widget> sliverChildren = [];
    String sliverTitle;

    if (selectedModule == null) {
      sliverTitle = S.of(context).module_catalog;
      sliverChildren = moduleCatalog
          .map((module) => DefaultPlatformText(module.name))
          .toList();
    } else {
      sliverTitle = S.of(context).module_configuration;
      if (tempModuleConfig.isEmpty) {
        sliverChildren = [
          const DefaultPlatformText(
              "No configuration available for this module!")
        ];
      } else {
        for (MapEntry<String, dynamic> entry in tempModuleConfig.entries) {
          String key = entry.key;
          var value = entry.value;
          sliverChildren.add(DefaultPlatformText(key));
          sliverChildren.add(PlatformTextFormField(
            // Use a custom key because this is somehow cached wrong
            key: Key("${selectedModule?.name}:$key"),
            initialValue: value,
            hintText: value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).fillOutField;
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.always,
            onChanged: (value) => saveConfigurationChange(key, value),
          ));
        }
      }
    }

    Widget secondWidget = Form(
      key: formKey,
      child: Flexible(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(sliverTitle),
              floating: true,
              automaticallyImplyLeading: false,
              backgroundColor: isMaterial(context)
                  ? ThemeData.dark().appBarTheme.backgroundColor
                  : darkCupertinoTheme.barBackgroundColor,
            ),
            SliverList(
              delegate: SliverChildListDelegate.fixed(sliverChildren),
            ),
          ],
        ),
      ),
    );

    List<Widget> columnChildren = [secondWidget];

    if (selectedModule != null && selectedModule!.hasConfig) {
      columnChildren.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              PlatformElevatedButton(
                child: Text(S.of(context).saveChanges),
                color: Colors.green,
                onPressed: formKey.currentState != null &&
                            formKey.currentState!.validate() ||
                        formKey.currentState == null
                    ? () => mirrorViewKey.currentState!.layout
                            .saveModuleConfiguration(
                          selectedModule!.position,
                          tempModuleConfig,
                        )
                    : null,
                padding: const EdgeInsets.all(8),
              ),
              PlatformElevatedButton(
                child: Text(S.of(context).cancel),
                color: Colors.red,
                onPressed: () => setSelectedModule(null),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ),
      );
    }

    Row finalWidget = Row(
      children: [
        // Container on the left
        mirrorContainer,
        // Other widget on the right with button overlay
        Expanded(
          child: Stack(
            children: [
              Column(
                children: columnChildren,
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 5, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: controlIcons,
                  ),
                ),
              )
            ],
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
