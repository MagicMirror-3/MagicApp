import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/introduction/introduction_page.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';
import 'package:magic_app/user/user_edit.dart';
import 'package:magic_app/util/communication_handler.dart';
import 'package:magic_app/util/safe_material_area.dart';
import 'package:magic_app/util/text_types.dart';
import 'package:magic_app/util/utility.dart';

import 'generated/l10n.dart';

/// Supplies a widget enabling the user to switch accounts or change their user info
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool enableButton = true;
  late MagicUser baseUser;

  @override
  void initState() {
    baseUser = SharedPreferencesHandler.getValue(SettingKeys.user);

    super.initState();
  }

  /// Opens the introduction screen to enable the user to create a new [MagicUser]
  /// with pictures, etc.
  void _openUserIntroduction(BuildContext context) {
    Navigator.push(
      context,
      platformPageRoute(
        context: context,
        builder: (_) => IntroductionPage(
          showPages: IntroductionPages.user,
          onDone: () {
            Navigator.pop(context);
            setState(() {
              baseUser = SharedPreferencesHandler.getValue(SettingKeys.user);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeMaterialArea(
      child: Stack(
        children: [
          Column(
            children: [
              // Icon for decoration purposes
              Padding(
                padding: const EdgeInsets.only(top: 64),
                child: Icon(
                  PlatformIcons(context).personOutline,
                  size: 150,
                  color: Colors.white,
                ),
              ),
              HeaderPlatformText(S.of(context).your_profile),
              // Input for first and last name
              Expanded(
                child: UserEdit(
                  key: Key(baseUser.toString()),
                  baseUser: baseUser,
                  onInputChanged: (valid) => setState(() {
                    enableButton = valid;
                  }),
                ),
              ),
              Padding(
                  padding:
                      const EdgeInsets.only(bottom: 20, left: 35, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PlatformElevatedButton(
                        child: DefaultPlatformText(S.of(context).deleteUser),
                        color: Colors.red,
                        onPressed: () async {
                          // change to the introduction screen

                          // Display a dialog window to cancel the deletion
                          showPlatformDialog(
                            context: context,
                            builder: (context) => PlatformAlertDialog(
                              title: const Text("Delete User"),
                              content: const Text(
                                  "Do you really want to delete the user?"),
                              actions: [
                                PlatformDialogAction(
                                  child: Text(S.of(context).cancel),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                PlatformDialogAction(
                                  child: Text(S.of(context).deleteUser),
                                  onPressed: () {
                                    // send a request to delete the user
                                    CommunicationHandler.deleteUser()
                                        .then((succesful) {
                                      if (succesful) {
                                        _openUserIntroduction(context);
                                      }
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(8),
                      ),
                      PlatformElevatedButton(
                        child: DefaultPlatformText(S.of(context).saveChanges),
                        color: Colors.green,
                        onPressed: enableButton
                            ? () {
                                // Get the data from the input
                                MagicUser tempUser =
                                    SharedPreferencesHandler.getValue(
                                  SettingKeys.tempUser,
                                );

                                // Save it locally ...
                                SharedPreferencesHandler.saveValue(
                                  SettingKeys.user,
                                  tempUser,
                                );

                                // ... and on the backend
                                CommunicationHandler.updateUserData();
                              }
                            : null,
                        padding: const EdgeInsets.all(8),
                      )
                    ],
                  )),
            ],
          ),
          // Switch user button
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: PlatformIconButton(
                padding: EdgeInsets.zero,
                // color: Colors.white,
                materialIcon: const Icon(Icons.switch_account_outlined),
                cupertinoIcon: const Icon(
                  CupertinoIcons.arrow_2_squarepath,
                  color: Colors.white,
                ),
                onPressed: () => _openUserIntroduction(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
