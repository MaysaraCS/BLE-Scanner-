import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ble_scanner_app/ble_controller.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:typed_data';

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
        init: BleController.uid(),
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
                  stream: controller.onFilteredScanResults,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          
                          final data = snapshot.data![index];
                          final serviceData =
                              data.advertisementData.serviceData;
                              //final uid = BleController.uid();
                              final tlm = BleController.tlm();


                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data.advertisementData.advName.isNotEmpty
                                        ? data.advertisementData.advName
                                        : data.device.platformName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text("MAC Address: ${data.device.remoteId}"),
                                  Text("RSSI: ${data.rssi}"),
                                  const SizedBox(height: 5),

                                  // Access the reactive URL variable
                                  Obx(() => Text(
                                      "URL: ${controller.url.value}")), // Displays the URL

                                  Text(
                                      "UUID Key: ${data.advertisementData.serviceUuids}"),
                                  Text("serviceData: ${serviceData}"),
                                  // Text(
                                  //     "TLM: ${data.advertisementData.txPowerLevel}"),
                                  Text(
                                      "TLM: ${tlm.serviceData.isNotEmpty ? tlm : 'N/A'}"),
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
