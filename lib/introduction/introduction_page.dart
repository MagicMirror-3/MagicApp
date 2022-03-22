import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:magic_app/main.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';
import 'package:magic_app/util/connect_mirror.dart';
import 'package:magic_app/util/text_types.dart';
import 'package:magic_app/util/themes.dart';

import '../user/user_edit.dart';
import '../util/utility.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  _IntroductionPageState createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final GlobalKey<IntroductionScreenState> introKey =
      GlobalKey(debugLabel: "IntroStateKey");
  bool mirrorConnected = false;
  bool userCreated = false;
  int currentPage = 0;

  void _onDone(BuildContext context) {
    SharedPreferencesHandler.saveValue(
      SettingKeys.firstUse,
      false,
    );

    MagicApp.of(context)?.refreshApp();
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      key: introKey,
      freeze: true,
      isProgressTap: false,
      globalBackgroundColor: isMaterial(context)
          ? Theme.of(context).scaffoldBackgroundColor
          : darkCupertinoTheme.scaffoldBackgroundColor,
      rawPages: [
        ConnectMirror(
          onSuccessfulConnection: () => setState(() {
            mirrorConnected = true;
            introKey.currentState!.next();
          }),
        ),
        UserEdit(
          baseUser: const MagicUser(),
          onInputChanged: (valid) => setState(() {
            userCreated = valid;
          }),
        ),
      ],
      done: const DefaultPlatformText("Done"),
      onDone: () => _onDone(context),
      next: const DefaultPlatformText("Next"),
      onChange: (pageIndex) {
        setState(() {
          currentPage = pageIndex;
        });
      },
      showNextButton: currentPage == 0 && mirrorConnected ||
          currentPage == 1 && userCreated,
      back: const DefaultPlatformText("Back"),
      showBackButton: currentPage == 2,
    );
  }
}
