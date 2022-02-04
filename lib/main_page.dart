import 'package:flutter/material.dart';
import 'package:magic_app/mirror/mirror_container.dart';
import 'package:magic_app/util/text_types.dart';

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
        const HeaderPlatformText("Hallo $userName!"),
        MirrorContainer(
          selectedModuleCallback: (module) => "this is a void module: $module",
        )
      ],
    );
  }
}
