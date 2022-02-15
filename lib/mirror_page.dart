import 'package:flutter/material.dart';
import 'package:magic_app/mirror/mirror_container.dart';
import 'package:magic_app/util/text_types.dart';

import 'generated/l10n.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const String userName = "Max Mustermann";

  @override
  void initState() {
    super.initState();

    requestModules();
  }

  bool modulesLoading = true;

  void requestModules() {
    Future.delayed(const Duration(seconds: 3)).then((_) {
      // Save the layout to local shared preferences
      //     MirrorLayout mirrorLayout = MirrorLayout.fromString("""[
      // {
      //   "module": "clock",
      //   "position": "top_right"
      // },
      // {
      //   "module": "weather",
      //   "position": "middle_center"
      // }
      //     ]""");
      //
      //     SharedPreferencesHandler.saveValue(
      //         SettingKeys.mirrorLayout, mirrorLayout);

      // Dont display loading screen
      if (mounted) {
        setState(() => modulesLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeaderPlatformText(S.of(context).greetings(userName)),
        MirrorContainer(
          onModuleChanged: (module) => "this is a void callback: $module",
          displayLoading: modulesLoading,
        )
      ],
    );
  }
}
