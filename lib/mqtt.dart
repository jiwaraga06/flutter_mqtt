import 'dart:async';
import 'dart:convert';
// import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mqtt/GistFile/gistFile.dart';
import 'package:flutter_mqtt/model/model.dart';
import 'package:marquee/marquee.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Mqtt extends StatefulWidget {
  static final Mqtt _singleton = Mqtt._internal();

  factory Mqtt() {
    return _singleton;
  }
  // const Mqtt({super.key});

  Mqtt._internal();

  @override
  State<Mqtt> createState() => _MqttState();
}

class _MqttState extends State<Mqtt> {
  String messageFromBroker = 'Idle';
  bool? isConnected;
  String connectButtonTitle = 'Connect';
  String disconnectButtonTitle = 'Disconnect';
  List<MyModel>? model;
  String stb = "";
  int? pesan;
  var nilai = [];
  String gabungNilai = " ";
  var tester = ['satu', 'dua'];
  var cek = 'cek1'
      'cek2'
      'cek3'
      'cek4   ';

  //nilai
  double nilai1 = 0;
  double nilai2 = 0;
  double iN = 0;
  double out = 0;
  double delta = 0;

  // DYEING 2
  // 3.80,1.00;231.80,0.00

  // PRINTING
  // 219.00;196.00;23.00
  // IN OUT DELTA

  // String broker = 'mq01.sipatex.co.id';
  // int port = 8838;
  // String username = 'it';
  // String password = 'it1234';
  // String clientIdentifier = 'mqttx_58a96ab2';
  MqttServerClient? client;
  StreamSubscription? subscription;
  List<MyModel> gaugeModel = [];

  Future<MqttServerClient> connect() async {
    MqttServerClient client = MqttServerClient.withPort(
      'mq01.sipatex.co.id',
      '$stb',
      8838,
    );
    client.logging(on: true);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    // client.onUnsubscribed = onUnsubscribed;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;
    client.secure = true;

    final connMessage = MqttConnectMessage()
        .authenticateAs('it', 'it1234')
        .keepAliveFor(60)
        .withWillTopic('Will Topics')
        .withWillMessage('Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;
    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);

//       < 200 - 170 kuning
// 250 maks hijau
// sisanya merah
      // print('Received message: $message');
      // print('Received message pay: $payload from topic: ${c[0].topic}>');
      if (c[0].topic == "/2022/Majalaya/Dyeing2/temperature_pressure") {
        var datas = payload.split(';');
        var data = payload.split(';')[0].split(',')[0];
        var data2 = payload.split(';')[1].split(',')[0];
        double nilai = double.parse(data);
        double nilaiBesar = double.parse(data2);
        setState(() {
          nilai1 = nilai;
          nilai2 = nilaiBesar;
        });
        // print("DATA DYEING: $datas");
      }
      if (c[0].topic == "/2022/Majalaya/Printing2/temperature") {
        var data = payload.split(';');
        double parseIN = double.parse(data[0]);
        double parseOUT = double.parse(data[1]);
        double parseDELTA = double.parse(data[2]);
        setState(() {
          iN = parseIN;
          out = parseOUT;
          delta = parseDELTA;
        });
        // print("DATA PRINTING: $data");
      }
      if (c[0].topic == "/2022/Majalaya/produksi/display1") {
        var data = payload;
        setState(() {
          nilai.add("$data");
          // gabungNilai = nilai.join(' ');
          gabungNilai = data;
          if (nilai.length == 2) {
            nilai.removeAt(0);
          }
        });
        print("DATA DISPLAY: $gabungNilai");
      }
      // BAIK, Tekanan UAP DF2 Lebih 4.50 Bar Tanggal  : 2022-11-10 Waktu     : 9:42:40 AM Tekanan : 4.50 Bar
      if (c[0].topic == "/Coba123/Pesan") {
        var data = jsonDecode(payload.toString());
        print("DATA PESAN: $data");
// gabungNilai = "tester";
        // print(nilai);
      }
    });
    client.subscribe("/2022/Majalaya/Dyeing2/temperature_pressure", MqttQos.atMostOnce);
    client.subscribe("/2022/Majalaya/Printing2/temperature", MqttQos.atMostOnce);
    client.subscribe("/2022/Majalaya/produksi/display1", MqttQos.atMostOnce);
    client.subscribe("/Coba123/Pesan", MqttQos.atMostOnce);
    return client;
  }

  @override
  void initState() {
    super.initState();
    int random = Random().nextInt(100000);
    setState(() {
      stb = "STB_ANDROID_mqttx_${random}";
    });
    Future.delayed(Duration(seconds: 1));
    connect();
    // print('STB_mqttx_ ${random}' );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.green,
      //   elevation: 0,
      //   title: Text('Flutter MQTT'),
      // ),
      body: Stack(
        children: [
          Positioned(
              bottom: 0.0,
              child: Container(
                color: Colors.grey[850],
                height: 40,
                width: MediaQuery.of(context).size.width,
                child: Marquee(
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        // accelerationDuration: Duration(milliseconds: 500),
                        blankSpace: 15.0,
                        text: gabungNilai,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
              )),
          ListView(
            children: [
              Column(
                children: [
                  const Divider(color: Colors.black, thickness: 2),
                  Text("Steam (UAP)", style: TextStyle(fontSize: 24)),
                  const Divider(color: Colors.black, thickness: 2),
                  Column(
                    children: [
                      Container(
                          height: 180,
                          child: SfRadialGauge(enableLoadingAnimation: true, animationDuration: 1000, axes: <RadialAxis>[
                            RadialAxis(minimum: 0, maximum: 11, ranges: <GaugeRange>[
                              GaugeRange(startValue: 0, endValue: 3, color: Colors.red, startWidth: 10, endWidth: 10),
                              GaugeRange(startValue: 3, endValue: 4.50, color: Colors.orange, startWidth: 10, endWidth: 10),
                              GaugeRange(startValue: 4.50, endValue: 11, color: Colors.green, startWidth: 10, endWidth: 10),
                            ], pointers: <GaugePointer>[
                              NeedlePointer(
                                  value: nilai1,
                                  animationDuration: 1000,
                                  animationType: AnimationType.ease,
                                  enableAnimation: true,
                                  needleColor: Colors.red,
                                  needleStartWidth: 1,
                                  needleEndWidth: 4,
                                  knobStyle: const KnobStyle(
                                    knobRadius: 0.05,
                                    borderColor: Colors.black,
                                    borderWidth: 0.02,
                                    color: Colors.white,
                                  ))
                            ], annotations: <GaugeAnnotation>[
                              GaugeAnnotation(
                                  widget: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Container(
                                      //   width: 30.00,
                                      //   height: 30.00,
                                      //   margin: const EdgeInsets.only(top: 12.0),
                                      //   decoration: const BoxDecoration(
                                      //     image: DecorationImage(
                                      //       image: ExactAssetImage('img/pressure.jpg'),
                                      //       fit: BoxFit.fitHeight,
                                      //     ),
                                      //   ),
                                      // ),
                                      Container(child: Text(nilai1.toString(), style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
                                      Text("Bar", style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                  angle: 90,
                                  positionFactor: 0.5)
                            ])
                          ])),
                      Text("Dyeing Finishing", style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Divider(color: Colors.black, thickness: 2),
                  Text("HTO", style: TextStyle(fontSize: 27)),
                  const Divider(color: Colors.black, thickness: 2),
                  const SizedBox(height: 20),
                  GridView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 3,
                      mainAxisSpacing: 3,
                      mainAxisExtent: 350,
                    ),
                    children: [
                      Container(
                        // height: 220,
                        // decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.black)),
                        child: Column(
                          children: [
                            Container(
                              height: 200,
                              child: SfRadialGauge(enableLoadingAnimation: true, animationDuration: 1000, axes: <RadialAxis>[
                                RadialAxis(minimum: 0, maximum: 250, ranges: <GaugeRange>[
                                  GaugeRange(startValue: 0, endValue: 170, color: Colors.red, startWidth: 10, endWidth: 10),
                                  GaugeRange(startValue: 170, endValue: 200, color: Colors.orange, startWidth: 10, endWidth: 10),
                                  GaugeRange(startValue: 200, endValue: 250, color: Colors.green, startWidth: 10, endWidth: 10),
                                ], pointers: <GaugePointer>[
                                  NeedlePointer(
                                      value: nilai2,
                                      animationDuration: 1000,
                                      animationType: AnimationType.ease,
                                      enableAnimation: true,
                                      needleColor: Colors.red,
                                      needleStartWidth: 1,
                                      needleEndWidth: 4,
                                      knobStyle: const KnobStyle(
                                        knobRadius: 0.05,
                                        borderColor: Colors.black,
                                        borderWidth: 0.02,
                                        color: Colors.white,
                                      ))
                                ], annotations: <GaugeAnnotation>[
                                  GaugeAnnotation(
                                      widget: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // Container(
                                          //   width: 25.00,
                                          //   height: 25.00,
                                          //   decoration: const BoxDecoration(
                                          //     image: DecorationImage(
                                          //       image: ExactAssetImage('img/tempe.jpg'),
                                          //       fit: BoxFit.fitHeight,
                                          //     ),
                                          //   ),
                                          // ),
                                          Container(
                                            // margin: const EdgeInsets.only(top: 60.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(nilai2.toString(), style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                                                Text("°C", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      angle: 90,
                                      positionFactor: 0.5)
                                ])
                              ]),
                            ),
                            Text("Dyeing Finishing", style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                      Container(
                        height: 220,
                        child: Column(
                          children: [
                            Container(
                              height: 200,
                              child: SfRadialGauge(enableLoadingAnimation: true, animationDuration: 1000, axes: <RadialAxis>[
                                RadialAxis(minimum: 0, maximum: 250, ranges: <GaugeRange>[
                                  GaugeRange(startValue: 0, endValue: 170, color: Colors.red, startWidth: 10, endWidth: 10),
                                  GaugeRange(startValue: 170, endValue: 200, color: Colors.orange, startWidth: 10, endWidth: 10),
                                  GaugeRange(startValue: 200, endValue: 250, color: Colors.green, startWidth: 10, endWidth: 10),
                                ], pointers: <GaugePointer>[
                                  NeedlePointer(
                                      value: iN,
                                      animationDuration: 1000,
                                      animationType: AnimationType.ease,
                                      enableAnimation: true,
                                      needleColor: Colors.red,
                                      needleStartWidth: 1,
                                      needleEndWidth: 4,
                                      knobStyle: const KnobStyle(
                                        knobRadius: 0.05,
                                        borderColor: Colors.black,
                                        borderWidth: 0.02,
                                        color: Colors.white,
                                      ))
                                ], annotations: <GaugeAnnotation>[
                                  GaugeAnnotation(
                                      widget: Container(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              iN.toString(),
                                              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                                            ),
                                            Text("°C", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      angle: 90,
                                      positionFactor: 0.5)
                                ])
                              ]),
                            ),
                            Text("IN", style: TextStyle(fontSize: 20)),
                            Text("Printing 2", style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                      Container(
                        height: 220,
                        child: Column(
                          children: [
                            Container(
                              height: 200,
                              child: SfRadialGauge(enableLoadingAnimation: true, animationDuration: 1000, axes: <RadialAxis>[
                                RadialAxis(minimum: 0, maximum: 250, ranges: <GaugeRange>[
                                  GaugeRange(startValue: 0, endValue: 170, color: Colors.red, startWidth: 10, endWidth: 10),
                                  GaugeRange(startValue: 170, endValue: 200, color: Colors.orange, startWidth: 10, endWidth: 10),
                                  GaugeRange(startValue: 200, endValue: 250, color: Colors.green, startWidth: 10, endWidth: 10),
                                ], pointers: <GaugePointer>[
                                  NeedlePointer(
                                      value: out,
                                      animationDuration: 1000,
                                      animationType: AnimationType.ease,
                                      enableAnimation: true,
                                      needleColor: Colors.red,
                                      needleStartWidth: 1,
                                      needleEndWidth: 4,
                                      knobStyle: const KnobStyle(
                                        knobRadius: 0.05,
                                        borderColor: Colors.black,
                                        borderWidth: 0.02,
                                        color: Colors.white,
                                      ))
                                ], annotations: <GaugeAnnotation>[
                                  GaugeAnnotation(
                                      widget: Container(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              out.toString(),
                                              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                                            ),
                                            Text("°C", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      angle: 90,
                                      positionFactor: 0.5)
                                ])
                              ]),
                            ),
                            Text("OUT", style: TextStyle(fontSize: 20)),
                            Text("Printing 2", style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                      Container(
                        height: 220,
                        child: Column(
                          children: [
                            Container(
                              height: 200,
                              child: SfRadialGauge(enableLoadingAnimation: true, animationDuration: 1000, axes: <RadialAxis>[
                                RadialAxis(minimum: 0, maximum: 250, ranges: <GaugeRange>[
                                  GaugeRange(startValue: 0, endValue: 100, color: Colors.green, startWidth: 10, endWidth: 10),
                                  GaugeRange(startValue: 100, endValue: 175, color: Colors.orange, startWidth: 10, endWidth: 10),
                                  GaugeRange(startValue: 175, endValue: 250, color: Colors.red, startWidth: 10, endWidth: 10),
                                ], pointers: <GaugePointer>[
                                  NeedlePointer(
                                      value: delta,
                                      animationDuration: 1000,
                                      animationType: AnimationType.ease,
                                      enableAnimation: true,
                                      needleColor: Colors.red,
                                      needleStartWidth: 1,
                                      needleEndWidth: 4,
                                      knobStyle: const KnobStyle(
                                        knobRadius: 0.05,
                                        borderColor: Colors.black,
                                        borderWidth: 0.02,
                                        color: Colors.white,
                                      ))
                                ], annotations: <GaugeAnnotation>[
                                  GaugeAnnotation(
                                      widget: Container(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              delta.toString(),
                                              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                                            ),
                                            Text("°C", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      angle: 90,
                                      positionFactor: 0.5)
                                ])
                              ]),
                            ),
                            Text("DELTA", style: TextStyle(fontSize: 20)),
                            Text("Printing 2", style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
