import 'package:ble_scanner_app/ble_controller.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("BLE SCANNER"),),
      body: GetBuilder<BleController>(
        init: BleController(),
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 150,
                  width:double.infinity,
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      "BLE SCANNER",
                          style:TextStyle(
                        color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      )
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(onPressed: ()=>controller.startScan(),
                      style:ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(350, 55),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        )
                      ),
                    child: const Text("Scan",
                  style: TextStyle(fontSize:18 ),
                  )),
                ),
                const SizedBox(height: 20),
                StreamBuilder<List<ScanResult>>(
                    stream: controller.scanResults,
                    builder:(context, snapshot){
                      if(snapshot.hasData){
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context,index)
                          {
                            final data = snapshot.data![index];
                            return Card(
                              elevation: 2,
                              child: ListTile(
                                title: Text(data.device.platformName),
                                // subtitle: Text(data.device.remoteId),
                                subtitle: Text(data.device.remoteId.toString()),
                                // trailing: Text(data.rssi.toString()),
                                trailing: Text("RSSI: ${data.rssi}"),
                                // for connection
                                //onTap: ()=> controller.connectToDevice(data.device),
                              ),
                            );
                          }
                        );

                      }else {
                        return const Center(child: Text("No Device Found"));
                      }
                    } )
              ],
            ),
          );
        },
      ),
    );
  }
}
