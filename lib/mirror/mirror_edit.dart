import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_app/mirror/mirror_container.dart';

import '../util/text_types.dart';

class MirrorEdit extends StatefulWidget {
  const MirrorEdit({Key? key}) : super(key: key);

  @override
  _MirrorEditState createState() => _MirrorEditState();
}

class _MirrorEditState extends State<MirrorEdit> {
  @override
  void initState() {
    super.initState();

    // Force landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void deactivate() {
    // Force portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: MirrorContainer(
            mirrorSize: 80,
            enableClick: false,
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const DefaultPlatformText("back"),
          ),
        ),
      ],
    );
  }
}
