

import 'dart:convert';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_desk_app/provider/printer_provider.dart';
import 'package:provider/provider.dart';

class PrinterPage extends StatefulWidget {

  const PrinterPage({super.key});

  @override
  State<StatefulWidget> createState() => PrinterPageState();
}

class PrinterPageState extends State<PrinterPage> {

  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool _connected = false;
  BluetoothDevice? _device;
  final TextStyle _titleStyle = const TextStyle(fontSize: 20, color: Colors.white);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }


  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    bool isConnected = await bluetoothPrint.isConnected ?? false;

    bluetoothPrint.state.listen((state) {
      print('******************* cur device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    PrinterProvider pp = Provider.of<PrinterProvider>(context, listen: true);

    return Scaffold(
        appBar: AppBar(
          //leading: new Container(),
          title: const Text("Printers"),

        ),
        body: Container(
          child: Row(
              children: [
                Expanded(
                    child:  Card(
                        color: Colors.black.withOpacity(0.5),
                        margin: const EdgeInsets.fromLTRB(20, 20, 10, 20),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            color: Colors.orange,
                          ),
                          borderRadius: BorderRadius.circular(10.0), //<-- SEE HERE
                        ),
                        child: Column(
                            children:[
                              Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.orange,
                                        width: 1,
                                      ),
                                    ),

                                  ),
                                  child: Row(
                                      children: [
                                        Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: Text("BLUETOOTH DEVICES", style: _titleStyle),

                                            )
                                        ),
                                      ]
                                  )
                              ),
                              Expanded(
                                  child: RefreshIndicator(
                                    onRefresh: () =>
                                        bluetoothPrint.startScan(
                                            timeout: Duration(seconds: 4)),
                                    child: StreamBuilder(
                                        stream: bluetoothPrint.scanResults,
                                        initialData: const [],
                                        builder: (ctx, snapshot) {
                                          return ListView.builder(
                                              itemCount: snapshot.data?.length ?? 0,
                                              itemBuilder: (BuildContext ctx, int index) {
                                                final element = snapshot
                                                    .data![index] as BluetoothDevice;
                                                return ListTile(
                                                  title: Text(element.name ?? "Unknown device"),
                                                  subtitle: Text(element.address??""),
                                                  //trailing: ,
                                                  onTap: () {
                                                    pp.setPrinter(element);
                                                  },

                                                );
                                              }
                                          );
                                        }
                                    ),
                                  )
                              ),
                            ]
                        )
                    )
                ),
                SizedBox(width:20),
                Expanded(
                    child: Card(
                        color: Colors.black.withOpacity(0.5),
                        margin: const EdgeInsets.fromLTRB(20, 20, 10, 20),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            color: Colors.orange,
                          ),
                          borderRadius: BorderRadius.circular(10.0), //<-- SEE HERE
                        ),
                        child: Column(
                            children:[
                              Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.orange,
                                        width: 1,
                                      ),
                                    ),

                                  ),
                                  child: Row(
                                      children: [
                                        Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: Text("PRINTER STATE", style: _titleStyle),

                                            )
                                        ),
                                      ]
                                  )
                              ),
                              Expanded(
                                  child: Container(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                          children: [
                                            Flexible(
                                                child: Row(
                                                    children: [
                                                      Text("DEVICE:"),
                                                      Text(pp.printer?.name??"Unknown"),
                                                    ]
                                                )
                                            ),
                                            Flexible(
                                                child: Row(
                                                    children: [
                                                      Text("STATUS:"),
                                                      FutureBuilder(
                                                        future: pp.isConnected(),
                                                        builder: (context, snapshot) {
                                                          if (snapshot.connectionState == ConnectionState.done) {
                                                            final data = snapshot.data as bool;
                                                            if (data) {
                                                              return Text("Connected");
                                                            } else {
                                                              return Text("DIsconnected");
                                                            }
                                                          } else {
                                                            return Center(
                                                              child: CircularProgressIndicator(),
                                                            );
                                                          }
                                                        },

                                                      ),
                                                    ]
                                                )
                                            )
                                          ]
                                      )
                                  )
                              )
                            ]
                        )
                    )
                )
              ]
          ),
        )
    );
  }
}

