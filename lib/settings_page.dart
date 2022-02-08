import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/settings/choices.dart';
import 'package:magic_app/settings/custom_ring_picker.dart';
import 'package:magic_app/util/shared_preferences_handler.dart';
import 'package:magic_app/util/utility.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Color prevColor = SharedPreferencesHandler.getValue(
    "wallColor",
    Colors.white,
  );

  void updateAlternativeAppearance(sliderValue, BuildContext context) {
    SharedPreferencesHandler.saveValue("alternativeAppearance", sliderValue);

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
    int wallPatternIndex = SettingChoices.wallBackgroundChoices.keys
        .toList()
        .indexOf(SharedPreferencesHandler.getValue("wallPattern", "wall.jpg"));

    int mirrorBorderIndex = SettingChoices.mirrorBorderChoices.keys
        .toList()
        .indexOf(
            SharedPreferencesHandler.getValue("mirrorBorder", "default.png"));

    return SettingsList(
      sections: [
        SettingsSection(
          title: const Text("App Appearance"),
          tiles: [
            SettingsTile.switchTile(
              initialValue: SharedPreferencesHandler.getValue(
                "darkMode",
                true,
              ),
              onToggle: (value) => print,
              title: const Text("Dark Mode"),
              leading: Icon(PlatformIcons(context).brightness),
            ),
            SettingsTile.switchTile(
              initialValue: SharedPreferencesHandler.getValue(
                "alternativeAppearance",
                false,
              ),
              onToggle: (value) => updateAlternativeAppearance(value, context),
              title: const Text("Alternative Appearance"),
            ),
          ],
        ),
        SettingsSection(
          title: const Text("Mirror Appearance"),
          tiles: [
            SettingsTile.navigation(
              title: const Text("Wall pattern"),
              value: Text(
                SettingChoices.wallBackgroundChoices.values
                    .toList()[wallPatternIndex],
              ),
              onPressed: (context) => isMaterial(context)
                  ? print("Open new window")
                  : showCupertinoDropdownPopup(
                      context: context,
                      items: SettingChoices.wallBackgroundChoices.values
                          .map((e) => Text(e))
                          .toList(),
                      initialItem: wallPatternIndex,
                      onIndexSelected: (index) => setState(() {
                        SharedPreferencesHandler.saveValue(
                            "wallPattern",
                            SettingChoices.wallBackgroundChoices.keys
                                .toList()[index]);
                      }),
                    ),
            ),
            SettingsTile(
              title: const Text("Wall color"),
              trailing: ColorIndicator(
                HSVColor.fromColor(prevColor),
                width: 25,
                height: 25,
              ),
              onPressed: (context) {
                Color tempColor = prevColor;

                showPlatformDialog(
                  context: context,
                  builder: (context) => PlatformAlertDialog(
                    title: const Text("Wall color"),
                    content: SingleChildScrollView(
                      child: CustomRingPicker(
                        pickerColor: SharedPreferencesHandler.getValue(
                          "wallColor",
                          prevColor,
                        ),
                        onColorChanged: (color) {
                          tempColor = color;
                        },
                        portraitOnly: true,
                      ),
                    ),
                    actions: [
                      PlatformDialogAction(
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.pop(context, prevColor),
                      ),
                      PlatformDialogAction(
                        child: const Text("Save"),
                        onPressed: () {
                          SharedPreferencesHandler.saveValue(
                            "wallColor",
                            tempColor,
                          );
                          Navigator.pop(context, tempColor);
                        },
                      ),
                    ],
                  ),
                ).then(
                  (value) => setState(() {
                    prevColor = value ?? prevColor;
                  }),
                );
              },
            ),
            SettingsTile.navigation(
              title: const Text("Mirror Border"),
              value: Text(
                SettingChoices.mirrorBorderChoices.values
                    .toList()[mirrorBorderIndex],
              ),
              onPressed: (context) => isMaterial(context)
                  ? print("Open new window")
                  : showCupertinoDropdownPopup(
                      context: context,
                      items: SettingChoices.mirrorBorderChoices.values
                          .map((e) => Text(e))
                          .toList(),
                      initialItem: mirrorBorderIndex,
                      onIndexSelected: (index) => setState(() {
                        SharedPreferencesHandler.saveValue(
                            "mirrorBorder",
                            SettingChoices.mirrorBorderChoices.keys
                                .toList()[index]);
                      }),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
