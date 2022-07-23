import 'package:flutter_test/flutter_test.dart';

import '../magic_test.dart';

/// Tests the functionality of the mirror components.
class MirrorTest extends MagicTest {
  MirrorTest() : super("Mirror");

  @override
  void unitTestImplementation() {
    test("placeholder test", () {
      expect(true, true);
    });
  }

  @override
  void widgetTestImplementation() {
    test("placeholder test", () {
      expect(true, true);
    });
  }
}
