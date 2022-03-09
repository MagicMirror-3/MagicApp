import 'package:flutter/material.dart';
import 'package:magic_app/main.dart';
import 'package:magic_app/util/communication_handler.dart';
import 'package:magic_app/util/magic_widgets.dart';
import 'package:magic_app/util/text_types.dart';

class ConnectMirror extends StatefulWidget {
  const ConnectMirror({Key? key}) : super(key: key);

  @override
  _ConnectMirrorState createState() => _ConnectMirrorState();
}

class _ConnectMirrorState extends State<ConnectMirror> {
  final List<Widget> _refreshChildren = [
    const HeaderPlatformText("Connect a mirror"),
    const Text(
      "Pull down to start searching for mirrors on your local network.",
      textAlign: TextAlign.center,
    ),
  ];

  void _onMirrorSelected(String ip) async {
    await CommunicationHandler.connectToMirror(mirrorIP: ip);
    MagicApp.of(context)?.refreshApp();
  }

  Future<bool> _refreshMirrors() async {
    List<String> mirrors = await CommunicationHandler.findLocalMirrors();

    if (mirrors.isNotEmpty) {
      _refreshChildren.removeAt(1);

      setState(() {
        for (String ip in mirrors) {
          _refreshChildren
              .add(_MirrorIPWidget(ip, (ip) => _onMirrorSelected(ip)));
        }
      });
    } else {
      _refreshChildren.add(
        const Text(
            "No mirrors found! Please make sure it is turned on and connected to your network!"),
      );
    }

    return mirrors.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MagicRefresher(
      onRefresh: _refreshMirrors,
      childWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _refreshChildren,
      ),
    );
  }
}

class _MirrorIPWidget extends StatelessWidget {
  const _MirrorIPWidget(this.ip, this.onSelected);

  final String ip;
  final Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(ip),
      child: Text("Mirror with IP: $ip"),
    );
  }
}
