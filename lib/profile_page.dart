import 'package:flutter/material.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';
import 'package:magic_app/util/communication_handler.dart';
import 'package:magic_app/util/magic_widgets.dart';
import 'package:magic_app/util/text_types.dart';
import 'package:magic_app/util/utility.dart';

import 'mirror/mirror_layout_handler.dart';
import 'mirror/module.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String mirrorFound = "";

  void _refreshNetworkDevices() async {
    // Try connecting to the mirror
    await CommunicationHandler.connectToMirror();

    if (CommunicationHandler.isConnected) {
      // Mirror is connected!
      setState(() {
        mirrorFound = "Successfully connected to mirror.\n";
      });

      print("Retrieving layout...");
      MirrorLayout? layout = await CommunicationHandler.getMirrorLayout();
      setState(() {
        mirrorFound += "\nThe layout is: $layout\n";
      });

      print("Retrieving users...");
      List<MagicUser> users = await CommunicationHandler.getUsers();

      setState(() {
        mirrorFound += "\nUsers:\n" + users.join("\n") + "\n";
      });

      print("Retrieving modules...");
      List<Module> modules = await CommunicationHandler.getModules();
      setState(() {
        mirrorFound += "\nModules:\n" + modules.join("\n");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 15),
          child: DefaultPlatformText(
            "Current User: ${SharedPreferencesHandler.getValue(SettingKeys.user)}",
          ),
        ),
        Expanded(
          child: MagicRefresher(
            initialRefresh: true,
            onRefresh: () async {
              _refreshNetworkDevices();
              return true;
            },
            childWidget: SingleChildScrollView(
              child: Text(mirrorFound),
            ),
          ),
        ),
      ],
    );
  }
}
