import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/util/communication_handler.dart';
import 'package:magic_app/util/magic_widgets.dart';
import 'package:magic_app/util/text_types.dart';

import '../generated/l10n.dart';
import '../util/safe_material_area.dart';

/// Lets the user search for MagicMirrors on the network and connect to any of the found mirrors.
class ConnectMirror extends StatefulWidget {
  const ConnectMirror({required this.onSuccessfulConnection, Key? key})
      : super(key: key);

  /// Will be called once a mirror was successfully connected to the app
  final void Function() onSuccessfulConnection;

  @override
  ConnectMirrorState createState() => ConnectMirrorState();
}

class ConnectMirrorState extends State<ConnectMirror> {
  /// A list of widgets being displayed under one another and containing Text and MagicMirrors
  List<Widget> _refreshChildren = [];

  /// Called once the user selected a MagicMirror with the given [ip]
  void _onMirrorSelected(String ip) async {
    if (await CommunicationHandler.connectToMirror(mirrorIP: ip)) {
      widget.onSuccessfulConnection();
    }
  }

  /// Do a broadcast request in the local network and check if there are any mirrors.
  /// If so, they are added to the [_refreshChildren]
  Future<bool> _refreshMirrors() async {
    if (_refreshChildren.length > 2) {
      _refreshChildren.removeAt(2);
    }

    // Scan the network
    List<String> mirrors = await CommunicationHandler.findLocalMirrors();

    if (mirrors.isNotEmpty) {
      // Only keep the header
      _refreshChildren = _refreshChildren.take(1).toList();

      // Create a clickable tile for every found MagicMirror
      for (String host in mirrors) {
        _refreshChildren.add(
          MagicListViewItem(
            leading: const Icon(Icons.crop_portrait),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DefaultPlatformText("Magic Mirror"),
                DefaultPlatformText("IP: $host"),
              ],
            ),
            onTap: () => _onMirrorSelected(host),
          ),
        );
      }
    } else {
      _refreshChildren.add(DefaultPlatformText(S.of(context).no_mirror_found));
    }

    // Check if the widget is still mounted to prevent errors
    if (mounted) {
      setState(() {});
    }

    // Return value is needed for the MagicRefresher
    return mirrors.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (_refreshChildren.isEmpty) {
      _refreshChildren = [
        HeaderPlatformText(S.of(context).connect_mirror),
        DefaultPlatformText(S.of(context).local_network_refresh),
      ];
    }

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
