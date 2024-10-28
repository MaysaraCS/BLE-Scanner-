import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  var _observedScanResults = <ScanResult>[].obs;

  FlutterBluePlus ble = FlutterBluePlus();

  Future<void> scanDevices() async {
    if (await Permission.bluetoothScan.request().isGranted) {
      await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 20), continuousUpdates: true);

      await Future.delayed(const Duration(seconds: 20), () {
        FlutterBluePlus.onScanResults.listen((results) {
          for (var result in results) {
            parseEddystoneData(result);
          }
          _observedScanResults.assignAll(results);
        }, onError: (error) {
          print(error);
        });
        FlutterBluePlus.stopScan();
      });
    }
  }

  void parseEddystoneData(ScanResult result) {
    final serviceData = result.advertisementData.serviceData;
    if (serviceData.isNotEmpty) {
      for (var entry in serviceData.entries) {
        var uuid = entry.key;
        // converts a list of bytes into a single, formatted hexadecimal string
        String hexValue =
            entry.value.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

        // Parse Eddystone data based on specific UUIDs or patterns in hex data
        // This is the Eddystone UUID
        if (uuid == '0000feaa-0000-1000-8000-00805f9b34fb') {
          // Eddystone UUID
          if (entry.value[0] == 0x00) {
            // Eddystone-UID
            String namespace = hexValue.substring(2, 22);
            String instance = hexValue.substring(22, 34);

            // now extract specific portions of hexValue to retrieve the Namespace and Instance components of the Eddystone UID frame.
            print("Eddystone UID - Namespace: $namespace, Instance: $instance");
          } else if (entry.value[0] == 0x10) {
            // Eddystone-URL
            String url = decodeEddystoneUrl(entry.value);
            print("Eddystone URL: $url");
          } else if (entry.value[0] == 0x20) {
            // Eddystone-TLM
            String version = hexValue.substring(2, 4);
            String voltage =
                int.parse(hexValue.substring(4, 8), radix: 16).toString();
            String temp =
                int.parse(hexValue.substring(8, 10), radix: 16).toString();
            print(
                "Eddystone TLM - Version: $version, Voltage: $voltage mV, Temperature: $temp °C");
          }
        } else {
          print("Service UUID: $uuid, Hex Value: $hexValue");
        }
      }
    }
  }

  String decodeEddystoneUrl(List<int> data) {
    const urlSchemes = ['http://www.', 'https://www.', 'http://', 'https://'];
    const urlExpansions = [
      '.com/',
      '.org/',
      '.edu/',
      '.net/',
      '.info/',
      '.biz/',
      '.gov/',
      '.com',
      '.org',
      '.edu',
      '.net',
      '.info',
      '.biz',
      '.gov'
    ];

    // initializes our variable url it to an empty string
    String url = '';
    // check if data array has more than 2 elements
    if (data.length > 2) {
      // retrive urlSchemes map 
      url += urlSchemes[data[2]] ?? '';
      for (int i = 3; i < data.length; i++) {
        if (data[i] < urlExpansions.length) {
          url += urlExpansions[data[i]];
        } else {
          // if data[i] is not found 
          // then convert the bytes to character 
          url += String.fromCharCode(data[i]);
        }
      }
    }
    return url;
  }

  Stream<List<ScanResult>> get onScanResults => FlutterBluePlus.onScanResults;
}

// The first byte of the payload indicates the frame type. For Eddystone, the frame types are defined as follows:
// 0x00: Eddystone-UID
// 0x10: Eddystone-URL
// 0x20: Eddystone-TLM (Telemetry)
