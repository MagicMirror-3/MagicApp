import 'package:flutter/material.dart';
import 'package:magic_app/text_types.dart';

class MirrorView extends StatefulWidget {
  const MirrorView({Key? key}) : super(key: key);

  @override
  _MirrorViewState createState() => _MirrorViewState();
}

class _MirrorViewState extends State<MirrorView> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: Column(
          children: [
            const Expanded(
              child: DefaultPlatformText("top_bar"),
            ),
            Expanded(
              child: Row(
                children: const [
                  Expanded(
                    child: DefaultPlatformText("top_left"),
                  ),
                  Expanded(
                    child: DefaultPlatformText("top_middle"),
                  ),
                  Expanded(
                    child: DefaultPlatformText("top_right"),
                  ),
                ],
              ),
              flex: 2,
            ),
            const Expanded(
              child: DefaultPlatformText("upper_third"),
              flex: 2,
            ),
            const Expanded(
              child: DefaultPlatformText("middle_center"),
              flex: 2,
            ),
            const Expanded(
              child: DefaultPlatformText("lower_third"),
              flex: 2,
            ),
            Expanded(
              child: Row(
                children: const [
                  Expanded(
                    child: DefaultPlatformText("bottom_left"),
                  ),
                  Expanded(
                    child: DefaultPlatformText("bottom_middle"),
                  ),
                  Expanded(
                    child: DefaultPlatformText("bottom_right"),
                  ),
                ],
              ),
              flex: 2,
            ),
            const Expanded(
              child: DefaultPlatformText("bottom_bar"),
            ),
          ],
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
