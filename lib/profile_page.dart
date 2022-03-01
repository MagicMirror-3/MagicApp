import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:magic_app/settings/constants.dart';
import 'package:magic_app/util/shared_preferences_handler.dart';
import 'package:magic_app/util/text_types.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Bluetooth stuff
  static FlutterBlue bluetooth = FlutterBlue.instance;
  static Set<BluetoothDevice> bluetoothDevices = {};

  void _discoverServices(BluetoothDevice device) {
    device.discoverServices().then((services) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BluetoothInfo(services: services),
        ),
      );
    });
  }

  void _listItemClick(BluetoothDevice device) {
    print("List item has been clicked");
    print(device);
    device.connect().then(
          (_) => _discoverServices(device),
          onError: (_) => _discoverServices(device),
        );
  }

  void _refreshBluetoothDevices() {
    // Clear device list
    bluetoothDevices.clear();

    // Start scanning for new devices
    bluetooth.startScan(timeout: const Duration(seconds: 4));
    bluetooth.scanResults.listen((results) {
      for (ScanResult result in results) {
        setState(() {
          bluetoothDevices.add(result.device);
        });
      }
    }).onError((err) {
      // print('Error => ' + err.toString());
    });

    bluetooth.stopScan();

    // Also add connected devices to the list
    bluetooth.connectedDevices.asStream().listen((connectedDevices) {
      for (BluetoothDevice device in connectedDevices) {
        setState(() {
          bluetoothDevices.add(device);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 15),
          child: DefaultPlatformText(
            "Current User: ${SharedPreferencesHandler.getValue(SettingKeys.userName)}",
          ),
        ),
        PlatformWidget(
          material: (_, __) => Expanded(
            child: ListView.builder(
              itemCount: bluetoothDevices.length,
              itemBuilder: (context, index) {
                BluetoothDevice device = bluetoothDevices.elementAt(index);

                return ListTile(
                  title: DefaultPlatformText(
                    device.name.isNotEmpty ? device.name : "No name",
                  ),
                  subtitle: DefaultPlatformText("Mac address: ${device.id}"),
                  onTap: () => _listItemClick(device),
                );
              },
            ),
          ),
          // https://github.com/flutter/flutter/pull/78732
          cupertino: (_, __) => DefaultPlatformText(
            bluetoothDevices.toString(),
          ),
        ),
        PlatformIconButton(
          icon: Icon(PlatformIcons(context).refresh),
          onPressed: _refreshBluetoothDevices,
        ),
      ],
    );
  }
}

class BluetoothInfo extends StatelessWidget {
  const BluetoothInfo({Key? key, required this.services}) : super(key: key);

  final List<BluetoothService> services;

  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = [];
    for (BluetoothService service in services) {
      columnChildren.add(Text("Service: $service"));
      for (BluetoothCharacteristic c in service.characteristics) {
        columnChildren.add(Text("Characteristic: $c"));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Info"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: columnChildren,
        ),
      ),
    );
  }
}
