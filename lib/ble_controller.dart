import 'package:get/get.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';

class BleController extends GetxController {
  // FlutterBluePlus ble = FlutterBluePlus();

  final RxList<ScanResult> _scanResults = <ScanResult>[].obs; // Reactive scan results
  final RxList<BluetoothService> _services = <BluetoothService>[].obs; // Reactive services list
  final RxMap<String, String> _readValues = <String, String>{}.obs; // Reactive read values
  BluetoothDevice? _selectedDevice; // Currently connected device
  final Map<String, bool> _connectionStatus = {};

  Future startScan() async {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4)).catchError((error) {
      print("Error starting scan: $error");
    });

    FlutterBluePlus.scanResults.listen((results) {
      _scanResults.value = results; // Update scan results
    });

    Future.delayed(const Duration(seconds: 4), () {
      FlutterBluePlus.stopScan();
    });
  }

  // Discover services for a connected device
  Future<void> discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    _services.value = services; // Update services reactively
  }

  // Read characteristic and decode the value
  Future<void> readCharacteristic(BluetoothCharacteristic characteristic) async {
    var value = await characteristic.read();
    String decodedValue = utf8.decode(value);
    _readValues[characteristic.uuid.toString()] = decodedValue; // Update the read values map

    // Instead of using context, use GetX's snackbar
    Get.snackbar(
      'Characteristic Read',
      'Read value: $decodedValue',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white,
    );
  }

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
}

