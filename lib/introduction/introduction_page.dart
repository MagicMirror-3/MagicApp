import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:magic_app/main.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  _IntroductionPageState createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
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
      pages: [
        PageViewModel(
          title: "Title of first page",
          body:
              "Here you can write the description of the page, to explain someting...",
          // image: Center(
          //   child:
          //       Image.network("https://domaine.com/image.png", height: 175.0),
          // ),
        ),
      ],
      done: const Text("Done"),
      onDone: () => _onDone(context),
      showNextButton: false,
    );
  }
}
