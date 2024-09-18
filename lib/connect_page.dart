import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'chat_page.dart';

class ConnectPage extends StatefulWidget {
  @override
  _ConnectPageState createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  bool isScanning = false;

  List<BluetoothDevice> devicesList = [];

  @override
  void initState() {
    super.initState();
    startScan();
  }

  void startScan() {
    try {
      var subscription = FlutterBluePlus.onScanResults.listen(
        (results) {
          if (results.isNotEmpty) {
            ScanResult r = results.last;
            print(
                '${r.device.remoteId}: "${r.advertisementData.advName}" found!');
          }
        },
        onError: (e) => print(e),
      );
      FlutterBluePlus.startScan(
        withServices: [Guid("180D")],
        withNames: ["Bluno"],
        timeout: Duration(seconds: 40),
      );
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (!devicesList.contains(r.device)) {
            setState(() {
              devicesList.add(r.device);
            });
          }
        }
      });
    } catch (err) {
      print("err ...     ${err}");
    }
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
    } catch (e) {
      print('Error disconnecting: $e');
    }

    try {
      await device.connect();
      print("Device connected...");
      print('Connected to ${device.name}');
    } catch (e) {
      print('Error connecting: $e');
    }

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ChatPage(device: device)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BLE Devices')),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.builder(
          itemCount: devicesList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(devicesList[index].name),
              subtitle: Text(devicesList[index].id.toString()),
              onTap: () => connectToDevice(devicesList[index]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          setState(() {
            devicesList.clear();
            startScan();
          });
        },
      ),
    );
  }

  Future onRefresh() {
    if (isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 40));
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(Duration(milliseconds: 500));
  }
}
