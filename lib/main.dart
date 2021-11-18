import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/default_platform_text.dart';
import 'package:magic_app/profile_page.dart';
import 'package:magic_app/settings_page.dart';

import 'main_page.dart';

void main() {
  runApp(const MagicApp());
}

class MagicApp extends StatelessWidget {
  const MagicApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(),
      child: PlatformProvider(
        settings: PlatformSettingsData(iosUsesMaterialWidgets: true),
        builder: (BuildContext context) => PlatformApp(
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          title: 'Magic App',
          // theme: ThemeData(
          //   // This is the theme of your application.
          //   //
          //   // Try running your application with "flutter run". You'll see the
          //   // application has a blue toolbar. Then, without quitting the app, try
          //   // changing the primarySwatch below to Colors.green and then invoke
          //   // "hot reload" (press "r" in the console where you ran "flutter run",
          //   // or simply save your changes to "hot reload" in a Flutter IDE).
          //   // Notice that the counter didn't reset back to zero; the application
          //   // is not restarted.
          //   primarySwatch: Colors.blue,
          //   brightness: Brightness.light,
          // ),
          home: const MagicHomePage(title: 'Magic App'),
          material: (_, __) => MaterialAppData(
            darkTheme: ThemeData(brightness: Brightness.dark),
            themeMode: ThemeMode.system,
          ),
          cupertino: (_, __) => CupertinoAppData(
            theme: const CupertinoThemeData(),
          ),
        ),
      ),
    );
  }
}

class MagicStartPage extends StatefulWidget {
  const MagicStartPage({Key? key}) : super(key: key);

  @override
  _MagicStartPageState createState() => _MagicStartPageState();
}

class _MagicStartPageState extends State<MagicStartPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


class MagicHomePage extends StatefulWidget {
  const MagicHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MagicHomePage> createState() => _MagicHomePageState();
}

class _MagicHomePageState extends State<MagicHomePage> {
  static int _selectedNavigationIndex = 0;

  static final List<Widget> _menuItemsContents = [
    const ProfilePage(),
    const MainPage(),
    const SettingsPage()
  ];

  void _onMenuItemTapped(int newIndex) {
    setState(() {
      _selectedNavigationIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    // print(platform(context));

    return PlatformScaffold(
      appBar: PlatformAppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        cupertino: (_, __) => CupertinoNavigationBarData(
          // Issue with cupertino where a bar with no transparency
          // will push the list down. Adding some alpha value fixes it (in a hacky way)
          backgroundColor: Colors.blue.withAlpha(254),
        ),
      ),
      body: Center(
        child: _menuItemsContents[_selectedNavigationIndex],
      ),
      bottomNavBar: PlatformNavBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(PlatformIcons(context).accountCircle),
            activeIcon: Icon(PlatformIcons(context).accountCircleSolid),
            label: "Profile",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.crop_portrait),
            label: "MagicMirror",
          ),
          BottomNavigationBarItem(
            icon: Icon(PlatformIcons(context).settings),
            activeIcon: Icon(PlatformIcons(context).settingsSolid),
            label: "Settings",
          ),
        ],
        currentIndex: _selectedNavigationIndex,
        itemChanged: _onMenuItemTapped,
      ),
    );
  }
}

class BluetoothInfo extends StatelessWidget {
  const BluetoothInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Info"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Back'),
        ),
      ),
    );
  }
}
