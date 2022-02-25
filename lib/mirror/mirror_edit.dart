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

  final GlobalKey<MirrorViewState> mirrorViewKey =
      GlobalKey<MirrorViewState>(debugLabel: "MirrorView");

  @override
  void initState() {
    selectedModule = widget.selectedModule;

    super.initState();

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
        selectedModule = module;
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

    if (isMaterial(context)) {
      controlIcons = controlIcons
          .map(
            (icon) => Material(
              child: icon,
              type: MaterialType.transparency,
              borderOnForeground: false,
            ),
          )
          .toList();
    }

    Widget secondWidget = Flexible(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
              title: Text(selectedModule == null
                  ? S.of(context).module_catalog
                  : S.of(context).module_configuration),
              floating: true,
              automaticallyImplyLeading: false,
              backgroundColor: isMaterial(context)
                  ? ThemeData.dark().appBarTheme.backgroundColor
                  : darkCupertinoTheme.barBackgroundColor),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              selectedModule == null
                  ? [
                      const DefaultPlatformText("Module1"),
                      const DefaultPlatformText("Module2"),
                      const DefaultPlatformText("Module3"),
                      const DefaultPlatformText("Module4"),
                      const DefaultPlatformText("Module5"),
                    ]
                  : [
                      const DefaultPlatformText("Configuration goes here"),
                    ],
            ),
          ),
        ],
      ),
    );

    List<Widget> columnChildren = [secondWidget];

    if (selectedModule != null) {
      columnChildren.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PlatformElevatedButton(
                child: const Text("Save changes"),
                color: Colors.green,
                onPressed: () => print("save"),
                padding: const EdgeInsets.all(8),
              ),
              PlatformElevatedButton(
                child: const Text("Restore Defaults"),
                color: Colors.grey,
                onPressed: () => print("restore"),
                padding: const EdgeInsets.all(8),
              ),
              PlatformElevatedButton(
                child: const Text("Cancel"),
                color: Colors.red,
                onPressed: () => setSelectedModule(null),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
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
  }
}
