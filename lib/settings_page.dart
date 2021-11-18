import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/default_platform_text.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const DefaultPlatformText("Settings"),
        PlatformElevatedButton(
          child: DefaultPlatformText(
            "Switch platform to ${isMaterial(context) ? "iOS" : "Android"}",
          ),
          onPressed: () {
            isMaterial(context)
                ? PlatformProvider.of(context)!.changeToCupertinoPlatform()
                : PlatformProvider.of(context)!.changeToMaterialPlatform();
          },
        ),
      ],
    );
  }
}
