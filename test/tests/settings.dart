import 'package:flutter_test/flutter_test.dart';

import '../magic_test.dart';

/// Tests the functionality of the settings components.
class SettingsTest extends MagicTest {
  SettingsTest() : super("Settings");

  @override
  void unitTestImplementation() {
    // Testing 'constants.dart' is useless since it's just constants
    test("SharedPreferencesHandler and PreferenceAdapter", () {
      // TODO: Test the functionality by saving, updating and deleting some values.
      //  Especially in edge-cases and wrong types, contents, etc.
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
