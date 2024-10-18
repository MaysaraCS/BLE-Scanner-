import 'package:get/get.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController{

  // FlutterBluePlus  ble = FlutterBluePlus.instance;
  FlutterBluePlus  ble = FlutterBluePlus();

  Future scanDevices() async{
    if(await Permission.bluetoothScan.request().isGranted){
      if(await Permission.bluetoothConnect.request().isGranted){
        FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
        FlutterBluePlus.stopScan();
      }
    }
  }
  // Listen to scan results
  // var subscription = FlutterBluePlus.scanResults.listen((results) {
  //   // do something with scan results
  //   for (ScanResult r in results) {
  //     print('${r.device.name} found! rssi: ${r.rssi}');
  //   }
  // });

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
}