import 'package:flutter/material.dart';
import 'package:magic_app/text_types.dart';

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
      children: const [
        HeaderPlatformText("Hallo $userName!"),
        Expanded(
            child: Center(
          child: DefaultPlatformText("Hier Mirror Oberfläche"),
        ))
      ],
    );
  }
}
