import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void updateAlternativeAppearance(sliderValue, BuildContext context) {
    if (sliderValue) {
      isMaterial(context)
          ? PlatformProvider.of(context)!.changeToCupertinoPlatform()
          : PlatformProvider.of(context)!.changeToMaterialPlatform();
    } else {
      PlatformProvider.of(context)!.changeToAutoDetectPlatform();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Consider using Settings UI -> fancier but more manual work
    return SettingsScreen(
      title: "Settings",
      children: [
        SettingsGroup(
          title: "Appearance",
          children: [
            SwitchSettingsTile(
              title: "Alternative Appearance",
              settingKey: "alternativeAppearance",
              subtitle:
                  "Enable the alternative Appearance (iOS on Android and vice versa)",
              onChange: (value) => updateAlternativeAppearance(value, context),
            ),
            DropDownSettingsTile(
              title: "Wall pattern",
              settingKey: "wallPattern",
              selected: "wall.jpg",
              values: const <String, String>{
                "wall.jpg": "Standard",
                "brick-wall.png": "Brick Wall",
                "brick-wall-dark.png": "Dark Brick Wall",
                "dark-brick-wall.png": "Dark Brick Wall 2",
                "concrete-wall.png": "Concrete",
                "concrete-wall-2.png": "Concrete 2",
                "concrete-wall-3.png": "Concrete 3",
                "redox-01.png": "Redox",
                "soft-wallpaper.png": "Soft",
                "white-wall.png": "White wall",
                "dark-wall.png": "Dark wall",
              },
            ),
            ColorPickerSettingsTile(
              title: "Wall color",
              settingKey: "wallColor",
              defaultValue: Colors.white,
            ),
            DropDownSettingsTile(
              title: "Mirror Border",
              settingKey: "borderImage",
              selected: "default.png",
              values: const <String, String>{
                "default.png": "IKEA Standard",
              },
            ),
          ],
        ),
      ],
    );
  }
}
