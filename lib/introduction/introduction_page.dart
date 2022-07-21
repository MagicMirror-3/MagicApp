import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:magic_app/introduction/connect_mirror.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';
import 'package:magic_app/user/user_select.dart';
import 'package:magic_app/util/text_types.dart';
import 'package:magic_app/util/themes.dart';

import '../main.dart';
import '../user/user_create.dart';
import '../util/utility.dart';
import 'face_detection.dart';

enum IntroductionPages {
  /// Show all pages (incl. connect mirror)
  all,

  /// Show only the user create process
  user
}

/// A step by step walkthrough about either the first experience in the app, or
/// the user creation process
class IntroductionPage extends StatefulWidget {
  const IntroductionPage({
    this.showPages = IntroductionPages.all,
    this.onDone,
    Key? key,
  }) : super(key: key);

  /// How many pages to show on the introduction screen
  final IntroductionPages showPages;

  /// Additional method to call once the introduction screen is over
  final Function()? onDone;

  @override
  IntroductionPageState createState() => IntroductionPageState();
}

class IntroductionPageState extends State<IntroductionPage> {
  final GlobalKey<IntroductionScreenState> introKey =
      GlobalKey(debugLabel: "IntroStateKey");
  bool mirrorConnected = false;
  bool nameInput = false;
  bool userCreated = false;
  int currentIndex = 0;

  /// This function is called once the user finished all introduction steps and is
  /// ready to use the app
  void _onDone(BuildContext context) {
    if (widget.showPages == IntroductionPages.all) {
      PreferencesAdapter.setFirstUse(false);
    }

    if (widget.onDone != null) {
      widget.onDone!();
    }

    MagicApp.of(context)?.refreshApp();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      if (widget.showPages == IntroductionPages.all)
        ConnectMirror(
          onSuccessfulConnection: () => setState(() {
            mirrorConnected = true;
            introKey.currentState!.next();
          }),
        ),
      UserSelect(
        onUserSelected: () => _onDone(context),
      ),
      UserCreate(
        onInputChanged: (valid) => setState(() {
          nameInput = valid;
        }),
      ),
      FaceRegistrationScreen(
        onFinished: (userID) {
          // print("Backed answered with $userID");
          if (userID != -1) {
            // Save the new user and set it as active
            MagicUser tempUser = PreferencesAdapter.tempUser;

            PreferencesAdapter.setActiveUser(MagicUser(
              id: userID,
              firstName: tempUser.firstName,
              lastName: tempUser.lastName,
            ));

            // Close this
            _onDone(context);
          } else {
            setState(() {
              userCreated = false;

              // return to the last introduction page
              introKey.currentState!.previous();
            });
          }
        },
      ),
    ];

    Widget currentPage = pages[currentIndex];

    return IntroductionScreen(
      key: introKey,
      freeze: true,
      isProgressTap: false,
      isBottomSafeArea: true,
      globalBackgroundColor: isMaterial(context)
          ? Theme.of(context).scaffoldBackgroundColor
          : darkCupertinoTheme.scaffoldBackgroundColor,
      rawPages: pages,
      done: const DefaultPlatformText("Done"),
      onDone: () => _onDone(context),
      // Show the done button only on the face screen if the user was created
      showDoneButton: currentPage is FaceRegistrationScreen && userCreated,
      next: DefaultPlatformText(
        currentPage is UserSelect ? "Create new user" : "Next",
      ),
      onChange: (pageIndex) {
        setState(() {
          currentIndex = pageIndex;
        });
      },
      // Show the next button only on selected pages
      showNextButton: currentPage is ConnectMirror && mirrorConnected ||
          currentPage is UserSelect ||
          currentPage is UserCreate && nameInput,
      back: const DefaultPlatformText("Back"),
      // Show the back button only on selected pages
      showBackButton: currentPage is UserCreate ||
          currentPage is FaceRegistrationScreen && !userCreated,
    );
  }
}
