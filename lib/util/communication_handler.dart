import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/util/shared_preferences_handler.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_tools/network_tools.dart';

class CommunicationHandler {
  static const int _port = 5000;

  static bool _connected = false;

  static bool get isConnected => _connected;
  static InternetAddress? _address;
  static String? _macAddress;
  static late http.Client _mirrorClient;

  static Future<List<String>> findLocalMirrors() async {
    final String? wifiIP = await NetworkInfo().getWifiIP();

    if (wifiIP != null) {
      final String subnet = wifiIP.substring(0, wifiIP.lastIndexOf("."));
      print("Searching on subnet $subnet");
      final hostStream = HostScanner.discover(subnet);

      List<String> mirrorList = [];

      // Go through every device
      await for (ActiveHost host in hostStream) {
        // Check if the desired port is open
        if ((await PortScanner.isOpen(host.ip, _port)).isOpen) {
          // Check if the device has magic mirror routes
          http.Response response = await http.get(
            createRouteURI(_MagicRoutes.isMagicMirror, host.ip),
          );

          if (response.statusCode == 200) {
            print("device found at ${host.ip}");
            mirrorList.add(host.ip);
          } else {
            print("this device does not have the mirror routes");
          }
        }
      }

      return mirrorList;
    } else {
      print("failed to retrieve IP");
      return [];
    }
  }

  static Future<bool> connectToMirror() async {
    final String savedAddress =
        SharedPreferencesHandler.getValue(SettingKeys.mirrorAddress);
    if (savedAddress.isNotEmpty) {
      print("Saved Address: $savedAddress");
    } else {
      final List<String> foundDevices = await findLocalMirrors();
      print("all devices: $foundDevices");

      if (foundDevices.length == 1) {
        print("Thankfully, only one mirror found: ");
        _mirrorClient = http.Client();
      }
    }

    _connected = true;
    // _address = await getIPbyMAC();

    // Send a request to the mirror
    return true;
  }

  static Uri createRouteURI(_MagicRoute route, dynamic host) {
    if (host == null) {
      host = _address!;
    } else {
      if (host is String) {
        host = InternetAddress(host, type: InternetAddressType.IPv4);
      }
    }

    if (host is InternetAddress) {
      return Uri.parse(host.address + "/" + route.route);
    } else {
      throw TypeError();
    }
  }
}

class _MagicRoutes {
  static const _MagicRoute isMagicMirror = _MagicRoute(route: "isMagicMirror");
  static const _MagicRoute createUser = _MagicRoute(
    route: "createUser",
    params: [
      "name",
    ],
  );
}

class _MagicRoute {
  const _MagicRoute({required this.route, this.params});

  final String route;
  final List<String>? params;
}
