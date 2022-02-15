import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/mirror/mirror_container.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/util/shared_preferences_handler.dart';

import '../util/text_types.dart';
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
    setState(() {
      selectedModule = moduleName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MirrorContainer(
          mirrorSize: 80,
          enableClick: false,
          displayLoading: false,
          selectedModule: selectedModule,
          onModuleChanged: setSelectedModule,
          mirrorViewKey: mirrorViewKey,
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PlatformTextButton(
                child: const DefaultPlatformText("save"),
                onPressed: () => SharedPreferencesHandler.saveValue(
                  SettingKeys.mirrorLayout,
                  mirrorViewKey.currentState?.layout,
                ),
              ),
              PlatformTextButton(
                child: const DefaultPlatformText("back"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
