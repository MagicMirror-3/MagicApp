import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/profile_page.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/settings_page.dart';
import 'package:magic_app/util/shared_preferences_handler.dart';

import 'generated/l10n.dart';
import 'mirror_page.dart';

void main() {
  // debugPrintGestureArenaDiagnostics = true;

  // Init Settings
  SharedPreferencesHandler.init().then((_) => runApp(const MagicApp()));
}

class MagicApp extends StatefulWidget {
  const MagicApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MagicAppState();

  static _MagicAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MagicAppState>();
}

class _MagicAppState extends State<MagicApp> {
  void refreshApp() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(),
      child: PlatformProvider(
        builder: (_) => PlatformApp(
          localizationsDelegates: const [
            S.delegate,
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          locale: Locale(
            SharedPreferencesHandler.getValue(SettingKeys.language),
          ),
          title: "Magic App",
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
          home: const MagicHomePage(),
          material: (_, __) => MaterialAppData(
            darkTheme: ThemeData.dark(),
            themeMode: SharedPreferencesHandler.getValue(SettingKeys.darkMode)
                ? ThemeMode.dark
                : ThemeMode.light,
          ),
          cupertino: (_, __) => CupertinoAppData(
            theme: const CupertinoThemeData(
              scaffoldBackgroundColor: Colors.black38,
              barBackgroundColor: Colors.black,
            ),
          ),
        ),
        initialPlatform: SharedPreferencesHandler.getValue(
                    SettingKeys.alternativeAppearance) ||
                !isMaterial(context)
            ? TargetPlatform.iOS
            : TargetPlatform.android,
      ),
    );
  }
}

class MagicHomePage extends StatefulWidget {
  const MagicHomePage({Key? key}) : super(key: key);

  @override
  State<MagicHomePage> createState() => _MagicHomePageState();
}

class _MagicHomePageState extends State<MagicHomePage> {
  static int _selectedNavigationIndex = 1;

  static final List<Widget> _menuItemsContents = [
    const ProfilePage(),
    const MainPage(),
    const SettingsPage()
  ];

  @override
  void initState() {
    super.initState();

    // Force portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

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
    final List<BottomNavigationBarItem> _bottomNavigationList = [
      BottomNavigationBarItem(
        icon: Icon(PlatformIcons(context).accountCircle),
        activeIcon: Icon(PlatformIcons(context).accountCircleSolid),
        label: S.of(context).profile,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.crop_portrait),
        label: S.of(context).magicMirror,
      ),
      BottomNavigationBarItem(
        icon: Icon(PlatformIcons(context).settings),
        activeIcon: Icon(PlatformIcons(context).settingsSolid),
        label: S.of(context).settings,
      ),
    ];

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(S.of(context).appName),
        material: (_, __) => MaterialAppBarData(),
        cupertino: (_, __) => CupertinoNavigationBarData(
          border: const Border(
            bottom: BorderSide(
              color: Colors.white12,
            ),
          ),
          transitionBetweenRoutes: true,
        ),
      ),
      body: Center(
        child: _menuItemsContents[_selectedNavigationIndex],
      ),
      bottomNavBar: PlatformNavBar(
        items: _bottomNavigationList,
        currentIndex: _selectedNavigationIndex,
        itemChanged: _onMenuItemTapped,
        material: (_, __) => MaterialNavBarData(),
        cupertino: (_, __) => CupertinoTabBarData(
          inactiveColor: Colors.white70,
          border: const Border(
            top: BorderSide(
              color: Colors.white12,
            ),
          ),
        ),
      ),
    );
  }
}
