import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';
import 'package:magic_app/user/user_create.dart';
import 'package:magic_app/util/text_types.dart';

import '../generated/l10n.dart';
import '../util/communication_handler.dart';
import '../util/magic_widgets.dart';
import '../util/safe_material_area.dart';
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
            HeaderPlatformText(S.of(context).select_user),
            DefaultPlatformText(S.of(context).select_user_or_create),
            _UserList(
              onUserSelected: userSelected,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: PlatformIconButton(
                icon: Icon(PlatformIcons(context).personAddSolid),
                onPressed: () => Navigator.push(
                  context,
                  platformPageRoute(
                    context: context,
                    maintainState: false,
                    builder: (_) => const UserCreate(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays a list of all available users for the user to choose from
class _UserList extends StatefulWidget {
  const _UserList({this.onUserSelected, Key? key}) : super(key: key);

  /// Calls the provided method with the selected User data
  final Function(MagicUser)? onUserSelected;

  @override
  State<StatefulWidget> createState() => _UserListState();
}

class _UserListState extends State<_UserList> {
  List<MagicListViewItem> items = [];

  @override
  void initState() {
    super.initState();

    // Create a list item for every user in the list
    // The callback is fired upon selection
    CommunicationHandler.getUsers().then(
      (userList) => setState(
        () => items = userList
            .map(
              (user) => MagicListViewItem(
                leading: Icon(PlatformIcons(context).person),
                content: Text(user.name),
                onTap: widget.onUserSelected != null
                    ? () => widget.onUserSelected!(user)
                    : null,
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isNotEmpty) {
      return Expanded(
        child: MagicListView(
          hasDivider: !isMaterial(context),
          shrinkWrap: true,
          children: items,
        ),
      );
    }

    // Otherwise display a loading widget
    return PlatformCircularProgressIndicator();
  }
}
