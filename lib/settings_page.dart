import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = true;

  @override
  Widget build(BuildContext context) {
    print("Dark Mode: $darkMode");
    return SettingsList(
      applicationType: ApplicationType.both,
      sections: [
        SettingsSection(
          title: const Text("Appearance"),
          tiles: [
            SettingsTile.switchTile(
              leading: Icon(PlatformIcons(context).brightness),
              initialValue: darkMode,
              onToggle: (value) {
                ;
              },
              title: const Text("Dark Mode"),
              description: const Text("Enables the dark mode."),
            ),
          ],
        ),
      ],
      brightness: Brightness.dark,
    );
  }
}
