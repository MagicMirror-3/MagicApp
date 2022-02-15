import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/mirror/mirror_container.dart';

import '../util/text_types.dart';

class MirrorEdit extends StatefulWidget {
  const MirrorEdit({this.selectedModule = "", Key? key}) : super(key: key);

  final String selectedModule;

  @override
  _MirrorEditState createState() => _MirrorEditState();
}

class _MirrorEditState extends State<MirrorEdit> {
  String selectedModule = "";

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
    print("MirrorEdit: $moduleName is selected");
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
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PlatformTextButton(
                child: const DefaultPlatformText("save"),
                onPressed: () => print("Save layout somehow"),
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
