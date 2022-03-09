import 'package:flutter/material.dart';
import 'package:magic_app/mirror/mirror_container.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';
import 'package:magic_app/util/communication_handler.dart';
import 'package:magic_app/util/magic_widgets.dart';
import 'package:magic_app/util/text_types.dart';
import 'package:magic_app/util/utility.dart';

import 'generated/l10n.dart';
import 'mirror/mirror_data.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool modulesLoading = SharedPreferencesHandler.getValue(
    SettingKeys.mirrorRefresh,
  );

  Future<bool> getLayout() async {
    if (!modulesLoading) {
      setState(() {
        modulesLoading = true;
      });
    }

    MirrorLayout? layout;
    if (CommunicationHandler.isConnected) {
      // Wait for the layout request
      layout = await CommunicationHandler.getMirrorLayout("abc");

      if (layout != null) {
        SharedPreferencesHandler.saveValue(SettingKeys.mirrorRefresh, false);
        SharedPreferencesHandler.saveValue(SettingKeys.mirrorLayout, layout);

        // Wait for cosmetic purposes
        Future.delayed(const Duration(seconds: 1)).then(
          (_) => setState(() {
            modulesLoading = false;
          }),
        );
      }
    }

    return layout != null;
  }

  @override
  Widget build(BuildContext context) {
    String userName =
        SharedPreferencesHandler.getValue<MagicUser>(SettingKeys.user).name;
    return MagicRefresher(
      initialRefresh: modulesLoading,
      onRefresh: getLayout,
      childWidget: Column(
        children: [
          HeaderPlatformText(S.of(context).greetings(userName)),
          MirrorContainer(
            key: Key("MirrorContainer_MirrorPage:$modulesLoading"),
            onModuleChanged: (module) => "this is a void callback: $module",
            displayLoading: modulesLoading,
          )
        ],
      ),
    );
  }
}
