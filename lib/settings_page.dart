import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/main.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/settings/custom_ring_picker.dart';
import 'package:magic_app/settings/settings_widgets.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';
import 'package:settings_ui/settings_ui.dart';

import 'generated/l10n.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Color prevColor = SharedPreferencesHandler.getValue(SettingKeys.wallColor);

  void updateDarkMode(bool sliderValue, BuildContext context) {
    SharedPreferencesHandler.saveValue(SettingKeys.darkMode, sliderValue);
    MagicApp.of(context)!.refreshApp();
  }

  void updateAlternativeAppearance(bool sliderValue, BuildContext context) {
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

  void updateLanguage(String language, BuildContext context) {
    if (S.delegate.supportedLocales.contains(Locale(language))) {
      SharedPreferencesHandler.saveValue(SettingKeys.language, language);
      S.load(Locale(language));
      MagicApp.of(context)!.refreshApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dark Mode tile
    // SettingsTile darkModeTile = SettingsTile.switchTile(
    //   initialValue: SharedPreferencesHandler.getValue(SettingKeys.darkMode),
    //   onToggle: (value) => updateDarkMode(value, context),
    //   title: Text(S.of(context).settings_darkMode),
    //   leading: Icon(PlatformIcons(context).brightness),
    // );

    // Alternative Appearance tile
    SettingsTile alternativeAppearanceTile = SettingsTile.switchTile(
      initialValue:
          SharedPreferencesHandler.getValue(SettingKeys.alternativeAppearance),
      onToggle: (value) => updateAlternativeAppearance(value, context),
      title: Text(S.of(context).settings_alternativeAppearance),
      leading: Icon(PlatformIcons(context).collections),
    );

    // Language tile
    LinkedMagicChoiceTile languageTile = LinkedMagicChoiceTile(
      title: S.of(context).settings_language,
      settingKey: SettingKeys.language,
      settingChoices: SettingChoices.languageChoices(context),
      selectCallback: (value) => updateLanguage(value, context),
      leading: const Icon(Icons.language_sharp),
    );

    // Wall pattern tile
    LinkedMagicChoiceTile wallPatternTile = LinkedMagicChoiceTile(
      title: S.of(context).settings_wallPattern,
      settingKey: SettingKeys.wallPattern,
      settingChoices: SettingChoices.wallPatternChoices(context),
      selectCallback: (value) => setState(() {
        SharedPreferencesHandler.saveValue(SettingKeys.wallPattern, value);
      }),
    );

    // Wall color tile
    SettingsTile wallColorTile = SettingsTile(
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
                pickerColor:
                    SharedPreferencesHandler.getValue(SettingKeys.wallColor),
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
    );

    // Mirror border tile
    LinkedMagicChoiceTile mirrorBorderTile = LinkedMagicChoiceTile(
      title: S.of(context).settings_mirrorBorder,
      settingKey: SettingKeys.mirrorFrame,
      settingChoices: SettingChoices.mirrorBorderChoices(context),
      selectCallback: (value) => setState(() {
        SharedPreferencesHandler.saveValue(SettingKeys.mirrorFrame, value);
      }),
    );

    // Quit on Save
    SettingsTile quitOnSaveTile = SettingsTile.switchTile(
      initialValue: SharedPreferencesHandler.getValue(SettingKeys.quitOnSave),
      onToggle: (value) => setState(
        () => SharedPreferencesHandler.saveValue(SettingKeys.quitOnSave, value),
      ),
      leading: Icon(PlatformIcons(context).checkMarkCircledOutline),
      title: Text(S.of(context).settings_quitOnSave),
      description: Text(S.of(context).settings_quitOnSaveDescription),
    );

    // Construct the layout
    return MagicSettingsList(
      sections: [
        SettingsSection(
          title: Text(S.of(context).settings_appAppearance),
          tiles: [
            // darkModeTile,
            alternativeAppearanceTile,
            languageTile,
          ],
        ),
        SettingsSection(
          title: Text(S.of(context).settings_mirrorAppearance),
          tiles: [
            wallPatternTile,
            wallColorTile,
            mirrorBorderTile,
            SettingsTile(
              title: const Text("Reset Layout"),
              onPressed: (_) => SharedPreferencesHandler.resetKey(
                SettingKeys.mirrorLayout,
              ),
            )
          ],
        ),
        SettingsSection(
          title: Text(S.of(context).settings_general),
          tiles: [
            quitOnSaveTile,
            SettingsTile(
              title: const Text("Reset Mirror Address"),
              onPressed: (_) => SharedPreferencesHandler.resetKey(
                SettingKeys.mirrorAddress,
              ),
            )
          ],
        )
      ],
    );
  }
}
