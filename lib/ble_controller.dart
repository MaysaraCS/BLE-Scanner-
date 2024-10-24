import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

class BleController {
  final List<ScanResult> scanResults = [];
  final Map<String, bool> connectionStatus = {};
  BluetoothDevice? selectedDevice; // Currently connected device
  List<BluetoothService> services = [];
  final Map<String, String> readValues = {};

  void startScan(Function updateState) {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4)).catchError((error) {
      print("Error starting scan: $error");
    });

    FlutterBluePlus.scanResults.listen((results) {
      scanResults.clear();
      scanResults.addAll(results);
      updateState(); // Call this function to update UI
    });

    Future.delayed(const Duration(seconds: 4), () {
      FlutterBluePlus.stopScan();
    });
  }

  void connectToDevice(BluetoothDevice device, Function updateState, Function showSnackbar) {
    device.connect(
      autoConnect: false,
      timeout: const Duration(seconds: 10),
    ).then((_) {
      connectionStatus[device.remoteId.str] = true;
      selectedDevice = device;
      _discoverServices(device, updateState);
      showSnackbar("Connected to ${device.platformName}");
    }).catchError((error) {
      showSnackbar("Failed to connect: $error");
      attemptReconnect(device, updateState, showSnackbar);
    });
  }

  void disconnectFromDevice(Function updateState, Function showSnackbar) {
    if (selectedDevice != null) {
      selectedDevice!.disconnect().then((_) {
        connectionStatus[selectedDevice!.remoteId.str] = false;
        services.clear();
        readValues.clear();
        selectedDevice = null;
        updateState();
        showSnackbar("Disconnected from ${selectedDevice!.platformName}");
      }).catchError((error) {
        showSnackbar("Failed to disconnect: $error");
      });
    }
  }

  void attemptReconnect(BluetoothDevice device, Function updateState, Function showSnackbar) {
    int attempts = 0;
    const maxAttempts = 3;

    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (attempts < maxAttempts) {
        device.connect(
          autoConnect: false,
          timeout: const Duration(seconds: 10),
        ).then((_) {
          connectionStatus[device.remoteId.str] = true;
          selectedDevice = device;
          _discoverServices(device, updateState);
          showSnackbar("Reconnected to ${device.platformName}");
          timer.cancel();
        }).catchError((error) {
          print("Reconnection attempt failed");
          attempts++;
        });
      } else {
        timer.cancel();
        showSnackbar("Max reconnection attempts reached. Please check the device or environment.");
      }
    });
  }

  void _discoverServices(BluetoothDevice device, Function updateState) async {
    List<BluetoothService> discoveredServices = await device.discoverServices();
    services = discoveredServices;
    updateState(); // Call this function to update UI
  }

  void readCharacteristic(BluetoothCharacteristic characteristic, Function updateState, Function showSnackbar) async {
    var value = await characteristic.read();
    String decodedValue = utf8.decode(value);
    readValues[characteristic.uuid.toString()] = decodedValue;
    updateState();
    showSnackbar('Read value: $decodedValue');
  }

  void writeCharacteristic(BluetoothCharacteristic characteristic, Function showSnackbar) async {
    int randomValue = Random().nextInt(999) + 1; // Random number between 1 and 999
    List<int> value = [randomValue & 0xFF, (randomValue >> 8) & 0xFF];
    await characteristic.write(value);
    showSnackbar('Written value: $randomValue');
  }

  void setNotification(BluetoothCharacteristic characteristic, Function showSnackbar) async {
    await characteristic.setNotifyValue(true);
    characteristic.lastValueStream.listen((value) {
      showSnackbar('Notification value: $value from ${characteristic.uuid}');
    });
  }
}
