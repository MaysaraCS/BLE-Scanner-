import 'package:ble_scanner_app/ble_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<BleController>(
        init: BleController(),
        builder: (controller) {
          return Column(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.blue,
                child: Center(
                  child: Text(
                    "BLE SCANNER",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => controller.scanDevices(),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(350, 55),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                  child: const Text(
                    "Scan",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<List<ScanResult>>(
                  stream: controller.onScanResults,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final data = snapshot.data![index];
                          return Card(
                            elevation: 2,
                            child: ListTile(
                              title: Text(
                                data.advertisementData.localName.isNotEmpty
                                    ? data.advertisementData.localName
                                    : data.device.platformName,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("ID: ${data.device.remoteId.toString()}"),
                                  Text("Services: ${data.advertisementData.serviceUuids.join(", ")}"),
                                  Text("Connectable: ${data.advertisementData.connectable ? "Yes" : "No"}"),
                                ],
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("RSSI: ${data.rssi.toString()}"),
                                  Text("Tx Power: ${data.advertisementData.txPowerLevel?.toString() ?? 'N/A'}"),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(child: Text("No Device Found"));
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
