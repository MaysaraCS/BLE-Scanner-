import 'package:flutter/material.dart';
import 'ble_controller.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late BleController _bleController;

  @override
  void initState() {
    super.initState();
    _bleController = BleController(); // Instantiate the BleController
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Bluetooth Device Scanner"),
      ),
      body: Center(
        child: _bleController.scanResults.isEmpty
            ? const Text('Scanning for Bluetooth devices...')
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _bleController.scanResults.length,
                itemBuilder: (context, index) {
                  final device = _bleController.scanResults[index].device;
                  final bool isConnected = _bleController.connectionStatus[device.remoteId.str] ?? false;

                  return ListTile(
                    leading: const Icon(Icons.bluetooth),
                    title: Text(device.platformName.isEmpty ? 'Unknown Device' : device.platformName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(device.remoteId.str),
                        Text('RSSI: ${_bleController.scanResults[index].rssi}'),
                      ],
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        if (isConnected) {
                          _bleController.disconnectFromDevice(() => setState(() {}), _showSnackBar);
                        } else {
                          _bleController.connectToDevice(device, () => setState(() {}), _showSnackBar);
                        }
                      },
                      child: Text(isConnected ? 'Disconnect' : 'Connect'),
                    ),
                  );
                },
              ),
            ),
            if (_bleController.services.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _bleController.services.length,
                  itemBuilder: (context, index) {
                    final service = _bleController.services[index];
                    return ExpansionTile(
                      title: Text('Service ${service.uuid}'),
                      children: service.characteristics.map((characteristic) {
                        return ListTile(
                          title: Text('Characteristic ${characteristic.uuid}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (characteristic.properties.read)
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _bleController.readCharacteristic(
                                        characteristic,
                                            () => setState(() {}),
                                        _showSnackBar,
                                      ),
                                      child: const Text('Read'),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _bleController.readValues[characteristic.uuid.toString()] ?? 'No value',
                                      style: const TextStyle(fontSize: 16, color: Colors.black),
                                    ),
                                  ],
                                ),
                              if (characteristic.properties.write)
                                ElevatedButton(
                                  onPressed: () => _bleController.writeCharacteristic(characteristic, _showSnackBar),
                                  child: const Text('Write Random Value'),
                                ),
                              if (characteristic.properties.notify)
                                ElevatedButton(
                                  onPressed: () => _bleController.setNotification(characteristic, _showSnackBar),
                                  child: const Text('Set Notification'),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _bleController.startScan(() => setState(() {})),
        tooltip: 'Rescan',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
