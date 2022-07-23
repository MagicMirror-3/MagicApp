import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Abstract superclass of all tests of the application.
///
/// Provides a scaffolding to unit and widget test components of the application.
///
/// All tests should extend this class and override the test implementations.
abstract class MagicTest {
  /// Create an instance of a test class containing unit and widget test with
  /// the given [name]
  MagicTest(this.name);

  /// The name of this test. Should be unique across the entire application
  final String name;

  /// Runs the unit tests in a group with the given [name] of this test class
  ///
  /// DO NOT OVERRIDE this method. Use [unitTestImplementation] to implement your tests.
  @nonVirtual
  void runUnitTests() {
    group("'$name' unit tests", () {
      unitTestImplementation();
    });
  }

  /// Runs the widget tests in a group with the given [name] of this test class
  ///
  /// DO NOT OVERRIDE this method. Use [widgetTestImplementation] to implement your tests.
  @nonVirtual
  void runWidgetTests() {
    group("'$name' widget tests", () {
      widgetTestImplementation();
    });
  }

  /// Override this method with your unit tests
  ///
  /// Should contain every unit test of the specified component
  void unitTestImplementation();

  /// Override this method with your widget tests
  ///
  /// Should contain every widget test of the specified component
  void widgetTestImplementation();
}