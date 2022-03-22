import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/main.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';
import 'package:magic_app/user/user_edit.dart';
import 'package:magic_app/user/user_select.dart';
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
                  baseUser: SharedPreferencesHandler.getValue(SettingKeys.user),
                  onInputChanged: (valid) => setState(() {
                    enableButton = valid;
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: PlatformElevatedButton(
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
                ),
              ),
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
                onPressed: () => Navigator.push(
                  context,
                  platformPageRoute(
                    context: context,
                    builder: (_) => UserSelect(
                      onUserSelected: () {
                        // Remove the user selection and refresh the entire app
                        Navigator.pop(context);
                        MagicApp.of(context)?.refreshApp();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
