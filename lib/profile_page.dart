import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';
import 'package:magic_app/util/communication_handler.dart';
import 'package:magic_app/util/text_types.dart';
import 'package:magic_app/util/utility.dart';

import 'mirror/mirror_data.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String mirrorFound = "";

  void _refreshNetworkDevices() async {
    // Try connecting to the mirror
    dynamic mirrorCandiates = await CommunicationHandler.connectToMirror();
    if (mirrorCandiates is List) {
      setState(() {
        mirrorFound = "Potential mirror candidates are: $mirrorCandiates";
      });
    } else {
      // Mirror is connected!
      setState(() {
        mirrorFound = "Successfully connected to mirror.";
      });

      print("Retrieving layout...");

      MirrorLayout? layout = await CommunicationHandler.getMirrorLayout("egal");
      setState(() {
        mirrorFound += "\nThe layout is: $layout";
      });

      print("Retrieving users...");

      List<MagicUser> users = await CommunicationHandler.getUsers();

      setState(() {
        mirrorFound += "\nUsers:\n" + users.join("\n");
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
            "Current User: ${SharedPreferencesHandler.getValue(SettingKeys.userName)}",
          ),
        ),
        Expanded(
          child: Text(mirrorFound),
        ),
        PlatformIconButton(
          icon: Icon(PlatformIcons(context).refresh),
          onPressed: _refreshNetworkDevices,
        ),
      ],
    );
  }
}

class BluetoothInfo extends StatefulWidget {
  const BluetoothInfo({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BluetoothInfoState();
}

class _BluetoothInfoState extends State<BluetoothInfo> {
  String helloMessage = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = [];
    columnChildren.add(PlatformTextButton(
      child: const Text("Send a test message"),
      onPressed: () => print("test message"),
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Network Info"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: columnChildren,
        ),
      ),
    );
  }
}
