import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/util/communication_handler.dart';
import 'package:magic_app/util/magic_widgets.dart';

/// Displays
class UserList extends StatefulWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<MagicListViewItem> items = [];

  @override
  void initState() {
    super.initState();

    CommunicationHandler.getUsers().then(
      (userList) => setState(
        () => items = userList
            .map(
              (user) => MagicListViewItem(
                leading: Icon(PlatformIcons(context).person),
                trailing: Icon(PlatformIcons(context).rightChevron),
                title: Text(user.name),
                onTap: () => print("User ${user.name} selected"),
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
          hasDivider: false,
          shrinkWrap: true,
          children: items,
        ),
      );
    }

    return PlatformCircularProgressIndicator();
  }
}
