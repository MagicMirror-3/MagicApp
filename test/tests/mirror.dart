import 'package:flutter_test/flutter_test.dart';
import 'package:magic_app/mirror/module.dart';

import '../magic_test.dart';

/// Tests the functionality of the mirror components.
class MirrorTest extends MagicTest {
  MirrorTest() : super("Mirror");

  @override
  void unitTestImplementation() {
    // TODO: Mock CommunicationHandler to support unit testing for the MirrorLayoutHandler
    test("Module class", () {
      Module noConfig = Module(
        name: "Unit-Testing",
        position: ModulePosition.top_center,
      );

      // Test the constructor
      expect(noConfig.originalPosition, ModulePosition.top_center);
      expect(noConfig.toString(), "Module: Unit-Testing");

      // Check whether the hasConfig getter is working as intended
      noConfig.config = {};
      expect(noConfig.hasConfig, false);
      noConfig.config!.putIfAbsent("unit", () => "test");
      expect(noConfig.hasConfig, true);
    });
  }

  @override
  void widgetTestImplementation() {
    test("placeholder test", () {
      expect(true, true);
    });
  }
}
