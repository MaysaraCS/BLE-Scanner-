import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

class BleController extends GetxController {
  var _observedScanResults = <ScanResult>[].obs;

  // Allowed MAC addresses for scanning
  final List<String> allowedMacAddresses = [
    "C3:00:00:1C:76:52",
    "C3:00:00:1C:76:51",
    "C3:00:00:1C:76:53"
  ];



  // Define advertising data properties
  final int flagsLen = 0x02;
  final int flagsType = 0x01;
  final int flagsValue = 0x06;

  final int uuidListLen = 0x03;
  final int uuidListType = 0x03;
  final Uint8List uuidListValue = Uint8List.fromList([0xAA, 0xFE]);

  late final int serviceDataLen;
  final int serviceDataType = 0x16;
  final Uint8List serviceDataUUID = Uint8List.fromList([0xAA, 0xFE]);
  late final Uint8List serviceData;

  // Define a MethodChannel for native interaction
  static const platform = MethodChannel('com.example.ble_scanner_app/ble');

  // Factory constructor for UID advertising
  BleController.uid()
      : serviceDataLen = 0x17,
        serviceData = Uint8List.fromList([
          0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
          0x07, 0x08, 0x09, 0x0A, 0x11, 0x22, 0x33, 0x44,
          0x55, 0x66, 0x00, 0x00
        ]);

  // Factory constructor for TLM advertising
  BleController.tlm()
      : serviceDataLen = 0x11,
        serviceData = Uint8List.fromList([
          0x20, 0x00, 0x00, 0x64, 0x48, 0x80, 0x00, 0x00,
          0x00, 0x01, 0x00, 0x00, 0x00, 0x02
        ]);

  // Function to start scanning devices
  Future<void> scanDevices() async {
    // Check for Bluetooth scan permission
    if (await Permission.bluetoothScan.request().isGranted) {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 20),
        continuousUpdates: true,
      );

      // Listen for scan results
      FlutterBluePlus.onScanResults.listen((results) {
        // Filter the results for specific MAC addresses
        final filteredResults = results.where((result) =>
            allowedMacAddresses.contains(result.device.remoteId.toString()));
        _observedScanResults.assignAll(filteredResults);
      }, onError: (error) {
        print("Scan error: $error");
      });
    } else {
      print("Bluetooth scan permission denied.");
    }
  }

  // // Start advertising UID using MethodChannel
  // Future<void> startAdvertisingUID() async {
  //   try {
  //     await platform.invokeMethod('startAdvertisingUID');
  //   } catch (e) {
  //     print("Failed to start UID advertising: $e");
  //   }
  // }

  // // Start advertising TLM using MethodChannel
  // Future<void> startAdvertisingTLM() async {
  //   try {
  //     await platform.invokeMethod('startAdvertisingTLM');
  //   } catch (e) {
  //     print("Failed to start TLM advertising: $e");
  //   }
  // }

  // Stream of filtered scan results
  Stream<List<ScanResult>> get onFilteredScanResults => _observedScanResults.stream;
}
