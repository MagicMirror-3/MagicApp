import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/util/communication_handler.dart';
import 'package:magic_app/util/magic_widgets.dart';
import 'package:magic_app/util/safe_material_area.dart';
import 'package:magic_app/util/utility.dart';

import '../mirror/mirror_layout_handler.dart';
import '../mirror/module.dart';

class APIPage extends StatefulWidget {
  const APIPage({Key? key}) : super(key: key);

  @override
  _APIPageState createState() => _APIPageState();
}

class _APIPageState extends State<APIPage> {
  String mirrorFound = "";

  void _refreshNetworkDevices() async {
    // Try connecting to the mirror
    await CommunicationHandler.connectToMirror();

    if (CommunicationHandler.isConnected) {
      // Mirror is connected!
      if (mounted) {
        setState(() {
          mirrorFound = "Successfully connected to mirror.\n";
        });
      }

      print("Retrieving layout...");
      MirrorLayout? layout = await CommunicationHandler.getMirrorLayout();
      _addToMirrorFound("\nThe layout is: $layout\n");

      print("Retrieving users...");
      List<MagicUser> users = await CommunicationHandler.getUsers();
      _addToMirrorFound("\nUsers:\n" + users.join("\n") + "\n");

      print("Retrieving modules...");
      List<Module> modules = await CommunicationHandler.getModules();
      _addToMirrorFound("\nModules:\n" + modules.join("\n"));
    }
  }

  /// This method wont be here for long...
  void _addToMirrorFound(String text) {
    if (mounted) {
      setState(() {
        mirrorFound += text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeMaterialArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          PlatformAppBar(
            title: const Text("API test"),
            automaticallyImplyLeading: true,
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
      ),
    );
  }
}
