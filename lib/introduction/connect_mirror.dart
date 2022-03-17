import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/main.dart';
import 'package:magic_app/util/communication_handler.dart';
import 'package:magic_app/util/magic_widgets.dart';
import 'package:magic_app/util/text_types.dart';
import 'package:network_tools/network_tools.dart';

import '../util/safe_material_area.dart';

/// Lets the user search for MagicMirrors on the network and connect to any of the found mirrors.
class ConnectMirror extends StatefulWidget {
  const ConnectMirror({Key? key}) : super(key: key);

  @override
  _ConnectMirrorState createState() => _ConnectMirrorState();
}

class _ConnectMirrorState extends State<ConnectMirror> {
  /// A list of widgets being displayed under one another and containing Text and MagicMirrors
  List<Widget> _refreshChildren = [
    const HeaderPlatformText("Connect a mirror"),
    const DefaultPlatformText(
      "Pull down to start searching for mirrors on your local network.",
    ),
  ];

  /// Called once the user selected a MagicMirror with the given [ip]
  void _onMirrorSelected(String ip) async {
    await CommunicationHandler.connectToMirror(mirrorIP: ip);
    MagicApp.of(context)?.refreshApp();
  }

  /// Do a broadcast request in the local network and check if there are any mirrors.
  /// If so, they are added to the [_refreshChildren]
  Future<bool> _refreshMirrors() async {
    if (_refreshChildren.length > 2) {
      _refreshChildren.removeAt(2);
    }

    // Scan the network
    List<ActiveHost> mirrors = await CommunicationHandler.findLocalMirrors();

    if (mirrors.isNotEmpty) {
      // Only keep the header
      _refreshChildren = _refreshChildren.take(1).toList();

      // Create a clickable tile for every found MagicMirror
      for (ActiveHost host in mirrors) {
        _refreshChildren.add(
          MagicListViewItem(
            leading: const Icon(Icons.crop_portrait),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultPlatformText(host.make),
                DefaultPlatformText("IP:${host.ip}"),
              ],
            ),
            onTap: () => _onMirrorSelected(host.ip),
          ),
        );
      }
    } else {
      _refreshChildren.add(
        const DefaultPlatformText(
          "No mirrors found! Please make sure it is turned on and connected to your network!",
        ),
      );
    }

    // Check if the widget is still mounted to prevent errors
    if (mounted) {
      setState(() {});
    } else {
      print("not mounted");
    }

    // Return value is needed for the MagicRefresher
    return mirrors.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return SafeMaterialArea(
      child: PlatformScaffold(
        body: MagicRefresher(
          onRefresh: _refreshMirrors,
          childWidget: Column(
            children: _refreshChildren,
          ),
        ),
      ),
    );
  }
}
