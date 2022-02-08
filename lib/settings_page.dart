import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/settings/custom_ring_picker.dart';
import 'package:magic_app/util/shared_preferences_handler.dart';
import 'package:magic_app/util/utility.dart';
import 'package:settings_ui/settings_ui.dart';

import 'generated/l10n.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Color prevColor = SharedPreferencesHandler.getValue(SettingKeys.wallColor);

  void updateAlternativeAppearance(sliderValue, BuildContext context) {
    SharedPreferencesHandler.saveValue(
      SettingKeys.alternativeAppearance,
      sliderValue,
    );

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
    final wallBackgroundChoices = SettingChoices.wallBackgroundChoices(context);
    int wallPatternIndex = wallBackgroundChoices.keys
        .toList()
        .indexOf(SharedPreferencesHandler.getValue(SettingKeys.wallPattern));

    final mirrorBorderChoices = SettingChoices.mirrorBorderChoices(context);
    int mirrorBorderIndex = mirrorBorderChoices.keys
        .toList()
        .indexOf(SharedPreferencesHandler.getValue(SettingKeys.mirrorBorder));

    final languageChoices = SettingChoices.languageChoices(context);
    int languageIndex =
        languageChoices.keys.toList().indexOf(Intl.getCurrentLocale());

    return SettingsList(
      sections: [
        SettingsSection(
          title: Text(S.of(context).settings_appAppearance),
          tiles: [
            SettingsTile.switchTile(
              initialValue:
                  SharedPreferencesHandler.getValue(SettingKeys.darkMode),
              onToggle: (value) => print,
              title: Text(S.of(context).settings_darkMode),
              leading: Icon(PlatformIcons(context).brightness),
            ),
            SettingsTile.switchTile(
              initialValue: SharedPreferencesHandler.getValue(
                  SettingKeys.alternativeAppearance),
              onToggle: (value) => updateAlternativeAppearance(value, context),
              title: Text(S.of(context).settings_alternativeAppearance),
            ),
            SettingsTile.navigation(
              title: Text(S.of(context).settings_language),
              value: Text(
                languageChoices.values.toList()[languageIndex],
              ),
              onPressed: (context) => isMaterial(context)
                  ? print("Open new window")
                  : showCupertinoDropdownPopup(
                      context: context,
                      items:
                          languageChoices.values.map((e) => Text(e)).toList(),
                      initialItem: languageIndex,
                      onIndexSelected: (index) => setState(() {
                        S.load(Locale(languageChoices.values.toList()[index]));
                      }),
                    ),
            ),
          ],
        ),
        SettingsSection(
          title: Text(S.of(context).settings_mirrorAppearance),
          tiles: [
            SettingsTile.navigation(
              title: Text(S.of(context).settings_wallPattern),
              value: Text(
                wallBackgroundChoices.values.toList()[wallPatternIndex],
              ),
              onPressed: (context) => isMaterial(context)
                  ? print("Open new window")
                  : showCupertinoDropdownPopup(
                      context: context,
                      items: wallBackgroundChoices.values
                          .map((e) => Text(e))
                          .toList(),
                      initialItem: wallPatternIndex,
                      onIndexSelected: (index) => setState(() {
                        SharedPreferencesHandler.saveValue(
                            SettingKeys.wallPattern,
                            wallBackgroundChoices.keys.toList()[index]);
                      }),
                    ),
            ),
            SettingsTile(
              title: Text(S.of(context).settings_wallColor),
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
                    title: Text(S.of(context).settings_wallColor),
                    content: SingleChildScrollView(
                      child: CustomRingPicker(
                        pickerColor: SharedPreferencesHandler.getValue(
                            SettingKeys.wallColor),
                        onColorChanged: (color) {
                          tempColor = color;
                        },
                        portraitOnly: true,
                      ),
                    ),
                    actions: [
                      PlatformDialogAction(
                        child: Text(S.of(context).cancel),
                        onPressed: () => Navigator.pop(context, prevColor),
                      ),
                      PlatformDialogAction(
                        child: Text(S.of(context).save),
                        onPressed: () {
                          SharedPreferencesHandler.saveValue(
                            SettingKeys.wallColor,
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
              title: Text(S.of(context).settings_mirrorBorder),
              value: Text(
                mirrorBorderChoices.values.toList()[mirrorBorderIndex],
              ),
              onPressed: (context) => isMaterial(context)
                  ? print("Open new window")
                  : showCupertinoDropdownPopup(
                      context: context,
                      items: mirrorBorderChoices.values
                          .map((e) => Text(e))
                          .toList(),
                      initialItem: mirrorBorderIndex,
                      onIndexSelected: (index) => setState(() {
                        SharedPreferencesHandler.saveValue(
                            SettingKeys.mirrorBorder,
                            mirrorBorderChoices.keys.toList()[index]);
                      }),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
