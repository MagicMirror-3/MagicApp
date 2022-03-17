import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';
import 'package:magic_app/user/user_list.dart';
import 'package:magic_app/util/safe_material_area.dart';
import 'package:magic_app/util/text_types.dart';

import '../util/utility.dart';

/// Gives the user the possibility to select a registered user
class UserSelect extends StatelessWidget {
  const UserSelect({this.onUserSelected, Key? key}) : super(key: key);

  /// An optional callback to call if a user was selected.
  ///
  /// Note: The value in the SharedPreferences is already updated by this class.
  final Function()? onUserSelected;

  /// Called whenever a user is selected from the list
  void userSelected(MagicUser user) {
    SharedPreferencesHandler.saveValue(SettingKeys.user, user);

    // Execute the callback, if provided
    if (onUserSelected != null) {
      onUserSelected!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeMaterialArea(
      child: PlatformScaffold(
        body: Column(
          children: [
            const HeaderPlatformText("Select a user"),
            const DefaultPlatformText(
              "Select a user out of the following list or create a new one",
            ),
            UserList(
              onUserSelected: userSelected,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: PlatformIconButton(
                icon: Icon(PlatformIcons(context).personAddSolid),
                onPressed: () => print("Create new user"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
