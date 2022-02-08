import 'package:flutter/material.dart';
import 'package:magic_app/mirror/mirror_container.dart';
import 'package:magic_app/util/text_types.dart';

import 'generated/l10n.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const String userName = "Max Mustermann";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeaderPlatformText(S.of(context).greetings(userName)),
        MirrorContainer(
          onModuleChanged: (module) => "this is a void callback: $module",
        )
      ],
    );
  }
}
