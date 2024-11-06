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

  // Reactive variable to hold the last URL found
  var url = 'N/A'.obs;
  var uid = 'N/A'.obs;
  var tlmData = 'N/A'.obs;

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
            _eddystoneUIDUpdate(hex, data.value, debugOrigin: 'serviceData');
            _eddystoneTLMUpdate(hex, data.value, debugOrigin: 'serviceData');
          }

          // Process manufacturer data
          for (var data in r.advertisementData.manufacturerData.entries) {
            var hex = decimalsToHex(data.value);
            _eddystoneUrlUpdate(hex, data.value,
                debugOrigin: 'manufacturerData');
            _eddystoneUIDUpdate(hex, data.value,
                debugOrigin: 'manufacturerData');
            _eddystoneTLMUpdate(hex, data.value,
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
    //FlutterBluePlus.stopScan();
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

  void _eddystoneUIDUpdate(String strData, List<int> originalInt,
      {String? debugOrigin}) {
    if (!strData.startsWith('00')) {
      return;
    }
    //print("str data :  $strData");
    //print("service data :  $serviceData");

    // UID structure: Namespace ID (10 bytes) + Instance ID (6 bytes)
    var namespaceId = originalInt
        .sublist(2, 12)
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join('');
    var instanceId = originalInt
        .sublist(12, 18)
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join('');
    uid.value = "Namespace ID: $namespaceId, Instance ID: $instanceId";
    print("UID: ${uid.value}");
  }

  void _eddystoneTLMUpdate(String strData, List<int> originalInt,
      {String? debugOrigin}) {
    if (!strData.startsWith('20')) {
      return;
    }
    //print("str data :  $strData");
    //print("service data :  $serviceData");

    // TLM structure: Battery Voltage (2 bytes), Temperature (2 bytes), Advertisement Count (4 bytes), Time Since Power-on (4 bytes)
    var batteryVoltage = (originalInt[2] << 8) | originalInt[3];
    var temperature = ((originalInt[4] << 8) | originalInt[5]) / 256;
    var advCount = (originalInt[6] << 24) |
        (originalInt[7] << 16) |
        (originalInt[8] << 8) |
        originalInt[9];
    var timeSincePowerOn = ((originalInt[10] << 24) |
            (originalInt[11] << 16) |
            (originalInt[12] << 8) |
            originalInt[13]) /
        10;

    tlmData.value =
        "Battery: $batteryVoltage mV, Temp: $temperature°C, Adv Count: $advCount, Uptime: $timeSincePowerOn s";
    print("TLM Data: ${tlmData.value}");
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
