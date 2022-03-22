import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/main.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';
import 'package:magic_app/user/user_edit.dart';
import 'package:magic_app/user/user_select.dart';
import 'package:magic_app/util/safe_material_area.dart';
import 'package:magic_app/util/text_types.dart';

import 'generated/l10n.dart';

/// Supplies a widget enabling the user to switch accounts or change their user info
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

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
                  hasSaveButton: true,
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
