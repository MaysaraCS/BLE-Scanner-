import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;

  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;


  @override
  void initState() {
    super.initState();

    @override
    void initState() {
      super.initState();

      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        _scanResults = results;
        if (mounted) { // by using if (mounted), you are checking whether the widget is still present in the widget tree before calling setState(),
          // preventing potential crashes.
          setState(() {});
        }
      }, onError: (e) {
          print("Scan Error: $e");
        // Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
      });

      _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
        _isScanning = state;
        if (mounted) {
          setState(() {});
        }
      });
    }
  }
  @override
  //Cancels the subscriptions to the streams when the widget is removed
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  // create a scanning function
  Future onScanPressed()async{
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      print("Start Scan Error: $e");
      // Snackbar.show(ABC.b, prettyException("Start Scan Error:", e), success: false);
    }
    if (mounted) {
      setState(() {});
    }
  }

  // create function for stopping the scanning
  Future onStopPressed()async{
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      print("Stop Scan Error: $e");
      // Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e), success: false);
    }
  }

  // after scanning we need a function for connection


  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
