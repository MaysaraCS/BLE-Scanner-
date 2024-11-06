import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

class BleController extends GetxController {
  var _observedScanResults = <ScanResult>[].obs;

  // Allowed MAC addresses for scanning
  final List<String> allowedMacAddresses = [
    "C3:00:00:1C:76:52",
    "C3:00:00:1C:76:51",
    "C3:00:00:1C:76:53"
  ];

  // Reactive variable to hold the last URL found
  var url = 'N/A'.obs; // Reactive variable

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

  // Factory constructor for UID advertising
  BleController.uid()
      : serviceDataLen = 0x17,
        serviceData = Uint8List.fromList([
          0x00,
          0x00,
          0x01,
          0x02,
          0x03,
          0x04,
          0x05,
          0x06,
          0x07,
          0x08,
          0x09,
          0x0A,
          0x11,
          0x22,
          0x33,
          0x44,
          0x55,
          0x66,
          0x00,
          0x00
        ]);
  // Factory constructor for TLM advertising
  BleController.tlm()
      : serviceDataLen = 0x11,
        serviceData = Uint8List.fromList([
          0x20,
          0x00,
          0x00,
          0x64,
          0x48,
          0x80,
          0x00,
          0x00,
          0x00,
          0x01,
          0x00,
          0x00,
          0x00,
          0x02
        ]);

  // Function to start scanning devices
  Future<void> scanDevices() async {
    // Check for Bluetooth scan permission
    if (await Permission.bluetoothScan.request().isGranted) {
      FlutterBluePlus.startScan(continuousUpdates: true);

      FlutterBluePlus.onScanResults.listen((results) async {
        for (ScanResult r in results) {
          // Process service data
          for (var data in r.advertisementData.serviceData.entries) {
            var hex = decimalsToHex(data.value);
            _eddystoneUrlUpdate(hex, data.value, debugOrigin: 'serviceData');
          }

          // Process manufacturer data
          for (var data in r.advertisementData.manufacturerData.entries) {
            var hex = decimalsToHex(data.value);
            _eddystoneUrlUpdate(hex, data.value,
                debugOrigin: 'manufacturerData');
          }
        }

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

  // Convert decimal bytes to hex string
  String decimalsToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
  }

  void _eddystoneUrlUpdate(String strData, List<int> originalInt,
      {String? debugOrigin}) {
    if (!strData.startsWith('10')) {
      return;
    }
    print("str data :  $strData");
    //print("service data :  $serviceData");

    var generatedUrl = eddystoneUrlDefinition(strData.substring(4, 6)) ?? '';
    print("URL before generated is $generatedUrl");

    generatedUrl += String.fromCharCodes(originalInt, 3);
    print("URL after  generated is $generatedUrl");

    // Update the reactive URL variable
    url.value = generatedUrl;
    print("URL is $generatedUrl");
  }

  String? eddystoneUrlDefinition(String hex) {
    switch (hex) {
      case '00':
        return 'http://www.';
      case '01':
        return 'https://www.';
      case '02':
        return 'http://';
      case '03':
        return 'https://';
      default:
    }
    return null;
  }

  // Stream of filtered scan results
  Stream<List<ScanResult>> get onFilteredScanResults =>
      _observedScanResults.stream;
}
