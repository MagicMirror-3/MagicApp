import 'package:flutter_test/flutter_test.dart';

import '../magic_test.dart';

/// Tests the functionality of the user components.
class UserTest extends MagicTest {
  UserTest() : super("User");

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
