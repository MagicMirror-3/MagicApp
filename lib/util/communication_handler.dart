import 'dart:io';

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

  static Future<List<String>> findLocalMirrors() async {
    final String? wifiIP = await NetworkInfo().getWifiIP();

    if (wifiIP != null) {
      final String subnet = wifiIP.substring(0, wifiIP.lastIndexOf("."));
      print("Searching on subnet $subnet");
      final hostStream = HostScanner.discover(subnet);

      List<String> _deviceList = [];

      await for (ActiveHost host in hostStream) {
        if ((await PortScanner.isOpen(host.ip, _port)).isOpen) {
          print("device found at ${host.ip}");
          _deviceList.add(host.ip);
        }
      }

      return _deviceList;
    } else {
      print("failed to retrieve IP");
      return [];
    }
  }

  static Future<bool> connectToMirror() async {
    final String savedMAC =
        SharedPreferencesHandler.getValue(SettingKeys.macAddress);
    if (savedMAC.isNotEmpty) {
      print("Saved MAC: $savedMAC");
    } else {
      final List<String> foundDevices = await findLocalMirrors();
      print("all devices: $foundDevices");
    }

    _connected = true;
    // _address = await getIPbyMAC();

    // Send a request to the mirror
    return true;
  }
}
