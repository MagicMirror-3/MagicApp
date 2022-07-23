import 'package:flutter_test/flutter_test.dart';
import 'package:magic_app/settings/shared_preferences_handler.dart';

import 'magic_test.dart';
import 'tests/introduction.dart';
import 'tests/mirror.dart';
import 'tests/settings.dart';
import 'tests/user.dart';
import 'tests/util.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    await SharedPreferencesHandler.init();
  });

  // Create a list of all the tests that will be run
  final tests = [
    IntroductionTest(),
    MirrorTest(),
    SettingsTest(),
    UserTest(),
    UtilTest()
  ];

  // Run the unit tests
  for (MagicTest t in tests) {
    t.runUnitTests();
  }
}