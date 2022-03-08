import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';
import 'package:magic_app/util/themes.dart';
import 'package:magic_app/util/utility.dart';
import 'package:settings_ui/settings_ui.dart';

import 'constants.dart';

class MagicSettingsList extends StatelessWidget {
  const MagicSettingsList({Key? key, required this.sections}) : super(key: key);

  final List<AbstractSettingsSection> sections;

  @override
  Widget build(BuildContext context) {
    return SettingsList(
      darkTheme: isMaterial(context)
          ? darkMaterialSettingsTheme
          : darkCupertinoSettingsTheme,
      lightTheme: isMaterial(context)
          ? lightMaterialSettingsTheme
          : lightCupertinoSettingsTheme,
      brightness: SharedPreferencesHandler.getValue(SettingKeys.darkMode)
          ? Brightness.dark
          : Brightness.light,
      applicationType: ApplicationType.both,
      sections: sections,
    );
  }
}

class MagicChoiceTile extends AbstractSettingsTile {
  const MagicChoiceTile(
      {Key? key,
      required this.title,
      required this.items,
      required this.index,
      required this.selectCallback,
      this.leading})
      : super(key: key);

  final String title;
  final List<String> items;
  final int index;
  final Function(int) selectCallback;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      cupertino: (context, __) => SettingsTile.navigation(
        title: Text(title),
        value: Text(
          items[index],
        ),
        onPressed: (_) => showCupertinoDropdownPopup(
          context: context,
          items: items.map((e) => Text(e)).toList(),
          initialItem: index,
          onIndexSelected: (selectedIndex) => selectCallback(selectedIndex),
        ),
        leading: leading,
      ),
      material: (context, __) => SettingsTile.navigation(
        title: Text(title),
        leading: leading,
        trailing: DropdownButton<String>(
          value: items[index],
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: (selectedString) =>
              selectCallback(items.indexOf(selectedString!)),
        ),
      ),
    );
  }
}

class LinkedMagicChoiceTile extends AbstractSettingsTile {
  const LinkedMagicChoiceTile(
      {Key? key,
      required this.title,
      required this.settingKey,
      required this.settingChoices,
      required this.selectCallback,
      this.leading})
      : super(key: key);

  final String title;
  final String settingKey;
  final Map<String, String> settingChoices;
  final Function(String) selectCallback;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    int languageIndex = settingChoices.keys
        .toList()
        .indexOf(SharedPreferencesHandler.getValue(settingKey));

    return MagicChoiceTile(
      title: title,
      items: settingChoices.values.toList(),
      index: languageIndex,
      selectCallback: (index) =>
          selectCallback(settingChoices.keys.toList()[index]),
      leading: leading,
    );
  }
}
