import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/util/communication_handler.dart';
import 'package:magic_app/util/magic_widgets.dart';

import '../util/utility.dart';

/// Displays a list of all available users for the user to choose from
class UserList extends StatefulWidget {
  const UserList({this.onUserSelected, Key? key}) : super(key: key);

  final Function(MagicUser)? onUserSelected;

  @override
  State<StatefulWidget> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
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
                trailing: Icon(PlatformIcons(context).rightChevron),
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
