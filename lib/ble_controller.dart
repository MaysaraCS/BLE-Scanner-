import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController{

  final List<ScanResult> _scanResults = [];
  final Map<String, bool> _connectionStatus = {};
  var _observedScanResults = <ScanResult>[].obs;  // Renamed to avoid conflict

  Future scanDevices() async{
    if(await Permission.bluetoothScan.request().isGranted){
      if(await Permission.bluetoothConnect.request().isGranted){
        FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
        //FlutterBluePlus.stopScan();
      }
      FlutterBluePlus.scanResults.listen((results) {
        _observedScanResults.assignAll(results);
      });
      Future.delayed(const Duration(seconds: 15), () {
        FlutterBluePlus.stopScan();
      });
    }
  }

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
}