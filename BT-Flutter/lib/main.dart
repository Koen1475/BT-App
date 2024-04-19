// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Bluetooth Scanner',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const BluetoothScanner(),
//     );
//   }
// }

// class BluetoothScanner extends StatefulWidget {
//   const BluetoothScanner({super.key});

//   @override
//   _BluetoothScannerState createState() => _BluetoothScannerState();
// }

// class _BluetoothScannerState extends State<BluetoothScanner> {
//   List<ScanResult> devices = [];
//   FlutterBluePlus flutterBlue = FlutterBluePlus();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Bluetooth Devices'),
//       ),
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: _startScanning,
//             child: const Text('Scan for Devices'),
//           ),
//           const SizedBox(height: 20),
//           if (devices.isNotEmpty)
//             Expanded(
//               child: ListView.builder(
//                 itemCount: devices.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(devices[index].device.name),
//                     // Implement onTap to connect to the selected device
//                     onTap: () {},
//                   );
//                 },
//               ),
//             )
//           else
//             const Text('No nearby devices found'),
//         ],
//       ),
//     );
//   }

//   void _startScanning() {
//     setState(() {
//       devices.clear(); // Clear the previous scan results
//     });

//     FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
//     FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
//       setState(() {
//         devices = results;
//       });
//     });
//   }
// }

// Copyright 2017-2023, Charles Weinberger & Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'screens/bluetooth_off_screen.dart';
import 'screens/scan_screen.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const FlutterBlueApp());
}

//
// This widget shows BluetoothOffScreen or
// ScanScreen depending on the adapter state
//
class FlutterBlueApp extends StatefulWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = _adapterState == BluetoothAdapterState.on
        ? const ScanScreen()
        : BluetoothOffScreen(adapterState: _adapterState);

    return MaterialApp(
      color: Colors.lightBlue,
      home: screen,
      navigatorObservers: [BluetoothAdapterStateObserver()],
    );
  }
}

//
// This observer listens for Bluetooth Off and dismisses the DeviceScreen
//
class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      // Start listening to Bluetooth state changes when a new route is pushed
      _adapterStateSubscription ??=
          FlutterBluePlus.adapterState.listen((state) {
        if (state != BluetoothAdapterState.on) {
          // Pop the current route if Bluetooth is off
          navigator?.pop();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // Cancel the subscription when the route is popped
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}
