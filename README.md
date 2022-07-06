# MagicApp
This repository contains the platform independent smartphone application of the [MagicMirror³](https://github.com/MagicMirror-3) project.

This application allows you to customize your layout and add new users to your MagicMirror.

## General information
The app is developed entirely with Flutter and Dart and contains no platform specific code.

Currently, the app can only be installed manually by cloning this repository and building and installing directly on your connected smartphone. Publishing it to the stores is definitely one of the next steps.

## How to install
1. Download and setup the latest version of Flutter simply by following [this](https://docs.flutter.dev/get-started/install) tutorial
2. Clone this repository
3. Open the project in your IDE of choice. We mainly use IntelliJ, but anything supporting Flutter projects is fine. In case you also want to use IntelliJ, we definitely recommend installing the _Flutter, Dart, Flutter Intl_ and _Flutter Enhancement Suite_ Plugins.
4. Install all packages by opening the project in a terminal and run the command `flutter pub get`
   1. The overridden dependency is due to an issue of a dependency introduced by upgrading to Flutter 3.0
5. Run the file `main.dart` either in an emulator or directly on your connected device

## Documentation
The documentation currently only consists of code comments, but we plan to extend this via GitHub wikis or other 3rd party tools.

## How to contribute
tbd.

