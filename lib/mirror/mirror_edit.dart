import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/mirror/mirror_container.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/util/shared_preferences_handler.dart';
import 'package:magic_app/util/text_types.dart';
import 'package:magic_app/util/themes.dart';

import 'mirror_view.dart';

class MirrorEdit extends StatefulWidget {
  const MirrorEdit({this.selectedModule = "", Key? key}) : super(key: key);

  final String selectedModule;

  @override
  _MirrorEditState createState() => _MirrorEditState();
}

class _MirrorEditState extends State<MirrorEdit> {
  String selectedModule = "";

  final GlobalKey<MirrorViewState> mirrorViewKey =
      GlobalKey<MirrorViewState>(debugLabel: "MirrorView");

  @override
  void initState() {
    selectedModule = widget.selectedModule;
    print("Edit opened with $selectedModule");

    super.initState();

    // Force landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void deactivate() {
    // Force portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.deactivate();
  }

  void setSelectedModule(String moduleName) {
    if (moduleName != selectedModule) {
      mirrorViewKey.currentState?.selectedModule = moduleName;
      setState(() {
        selectedModule = moduleName;
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

    Widget secondWidget =
        selectedModule == "" ? _ModuleCatalog() : const Placeholder();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        mirrorContainer,
        Expanded(
          child: Stack(
            children: [
              secondWidget,
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 28, 5, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: controlIcons,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModuleCatalog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text("Module catalog"),
          floating: true,
          automaticallyImplyLeading: false,
          backgroundColor: isMaterial(context)
              ? ThemeData.dark().appBarTheme.backgroundColor
              : darkCupertinoTheme.barBackgroundColor,
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            const DefaultPlatformText("Module1"),
            const DefaultPlatformText("Module2"),
            const DefaultPlatformText("Module3"),
            const DefaultPlatformText("Module4"),
            const DefaultPlatformText("Module5"),
          ]),
        ),
      ],
    );
  }
}
