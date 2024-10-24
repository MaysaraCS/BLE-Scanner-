import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController{
  final List<ScanResult> _scanResults = [];
  final Map<String, bool> _connectionStatus = {};
  var _observedScanResults = <ScanResult>[].obs;

  FlutterBluePlus  ble = FlutterBluePlus();

  Future scanDevices() async{
    if(await Permission.bluetoothScan.request().isGranted) {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 20),continuousUpdates: true);

      await Future.delayed(const Duration(seconds: 20), () {
        FlutterBluePlus.onScanResults.listen((results) {
          print(results);
          _observedScanResults.assignAll(results);
        },onError: (error){
          print(error);
        });
        FlutterBluePlus.stopScan();
      });
    }
  }
  Stream<List<ScanResult>> get onScanResults => FlutterBluePlus.onScanResults;
}
