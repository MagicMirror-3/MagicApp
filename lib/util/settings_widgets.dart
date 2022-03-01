import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/util/shared_preferences_handler.dart';
import 'package:magic_app/util/themes.dart';
import 'package:settings_ui/settings_ui.dart';

import '../settings/constants.dart';

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
