import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mqtt/GistFile/gistFile.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TemperaturHTO extends StatefulWidget {
  const TemperaturHTO({super.key});

  @override
  State<TemperaturHTO> createState() => _TemperaturHTOState();
}

class _TemperaturHTOState extends State<TemperaturHTO> {
  //printing2
  //steam 0-10bar
  //hto 0-250bar
  //dyeing2
  double inlet = 0.0;
  double outlet = 0.0;
  double delta = 0.0;
  double steam = 0.0;
  double htoinlet = 0.0;
  double htooutlet = 0.0;
  double htodelta = 0.0;
  String stb = "";
  Future<MqttServerClient> connect() async {
    MqttServerClient client = MqttServerClient.withPort(
      'mq01.sipatex.co.id',
      'TEST',
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
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Alert !'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text(e.toString())],
            ),
          );
        },
      );
      client.disconnect();
    }

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
      if (c[0].topic == "/2022/Majalaya/Printing2/temperature") {
        var data = payload.toString();
        setState(() {
          inlet = double.parse(data.toString().split(';')[0]);
          outlet = double.parse(data.toString().split(';')[1]);
          delta = double.parse(data.toString().split(';')[2]);
        });
        // print('inlet : $inlet');
        // print("DATA PRINTING2: $data");
      }
      if (c[0].topic == "/2022/Majalaya/Dyeing2/temperature_pressure") {
        var data = payload.toString();
        setState(() {
          steam = double.parse(data.toString().split(';')[0].split(',')[0]);
        });
        // print("DATA DYEING2: $data");
      }
      if (c[0].topic == "/2022/Majalaya/Dyeing2/temperatureHTO") {
        var data = payload.toString();
        setState(() {
          htoinlet = double.parse(data.toString().split(';')[0]);
          htooutlet = double.parse(data.toString().split(';')[1]);
          htodelta = double.parse(data.toString().split(';')[2]);
        });
        print("DATA DYEING2 HTO: $data");
      }
    });
    client.subscribe("/2022/Majalaya/Printing2/temperature", MqttQos.atMostOnce);
    client.subscribe("/2022/Majalaya/Dyeing2/temperature_pressure", MqttQos.atMostOnce);
    client.subscribe("/2022/Majalaya/Dyeing2/temperatureHTO", MqttQos.atMostOnce);
    return client;
  }

  @override
  void initState() {
    super.initState();
    int random = Random().nextInt(100000);
    setState(() {
      stb = "STB_ANDROID_mqttx_${random}";
    });
    Future.delayed(const Duration(seconds: 1));
    connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Steam Temperature Dyeing 2", style: TextStyle(fontSize: 18)),
                SizedBox(
                  height: 250,
                  child: SfRadialGauge(enableLoadingAnimation: true, animationDuration: 2500, axes: <RadialAxis>[
                    RadialAxis(
                        startAngle: 180,
                        endAngle: 0,
                        canScaleToFit: true,
                        minimum: 0,
                        interval: 1,
                        maximum: 10,
                        axisLabelStyle: const GaugeTextStyle(fontSize: 17),
                        annotations: <GaugeAnnotation>[
                          // GaugeAnnotation(
                          //   widget: Text(steam.toString(), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                          //   angle: 0,
                          //   positionFactor: 0.5,
                          // )
                        ],
                        pointers: <GaugePointer>[
                          NeedlePointer(value: steam, enableAnimation: true),
                        ],
                        ranges: <GaugeRange>[
                          GaugeRange(startValue: 0, endValue: 4, color: Colors.green, startWidth: 10, endWidth: 10),
                          GaugeRange(startValue: 4, endValue: 8, color: Colors.orange, startWidth: 10, endWidth: 10),
                          GaugeRange(startValue: 8, endValue: 10, color: Colors.red, startWidth: 10, endWidth: 10)
                        ])
                  ]),
                ),
                Text(steam.toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Text("STEAM", style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
              margin: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: Column(
                children: [
                  const Text("HTO Temperature Printing 2", style: TextStyle(fontSize: 18)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 2.0, bottom: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 300,
                                child: SfRadialGauge(enableLoadingAnimation: true, animationDuration: 2500, axes: <RadialAxis>[
                                  RadialAxis(
                                      minimum: 0,
                                      maximum: 250,
                                      interval: 25,
                                      axisLabelStyle: const GaugeTextStyle(fontSize: 17),
                                      annotations: <GaugeAnnotation>[
                                        GaugeAnnotation(
                                          widget: Text(inlet.toString(), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                                          angle: 90,
                                          positionFactor: 0.5,
                                        )
                                      ],
                                      pointers: <GaugePointer>[
                                        NeedlePointer(value: inlet, enableAnimation: true),
                                      ],
                                      ranges: <GaugeRange>[
                                        GaugeRange(startValue: 0, endValue: 80, color: Colors.green, startWidth: 10, endWidth: 10),
                                        GaugeRange(startValue: 80, endValue: 180, color: Colors.orange, startWidth: 10, endWidth: 10),
                                        GaugeRange(startValue: 180, endValue: 250, color: Colors.red, startWidth: 10, endWidth: 10)
                                      ])
                                ]),
                              ),
                              const Text("INLET", style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 2.0, bottom: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 300,
                                child: SfRadialGauge(enableLoadingAnimation: true, animationDuration: 2500, axes: <RadialAxis>[
                                  RadialAxis(
                                      minimum: 0,
                                      maximum: 250,
                                      interval: 25,
                                      axisLabelStyle: const GaugeTextStyle(fontSize: 17),
                                      annotations: <GaugeAnnotation>[
                                        GaugeAnnotation(
                                          widget: Text(outlet.toString(), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                                          angle: 90,
                                          positionFactor: 0.5,
                                        )
                                      ],
                                      pointers: <GaugePointer>[
                                        NeedlePointer(value: outlet, enableAnimation: true),
                                      ],
                                      ranges: <GaugeRange>[
                                        GaugeRange(startValue: 0, endValue: 80, color: Colors.green, startWidth: 10, endWidth: 10),
                                        GaugeRange(startValue: 80, endValue: 180, color: Colors.orange, startWidth: 10, endWidth: 10),
                                        GaugeRange(startValue: 180, endValue: 250, color: Colors.red, startWidth: 10, endWidth: 10)
                                      ])
                                ]),
                              ),
                              const Text("OUTLET", style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 2.0, bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 300,
                                child: SfRadialGauge(enableLoadingAnimation: true, animationDuration: 2500, axes: <RadialAxis>[
                                  RadialAxis(
                                      minimum: 0,
                                      maximum: 250,
                                      interval: 25,
                                      axisLabelStyle: const GaugeTextStyle(fontSize: 17),
                                      annotations: <GaugeAnnotation>[
                                        GaugeAnnotation(
                                          widget: Text(delta.toString(), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                                          angle: 90,
                                          positionFactor: 0.5,
                                        )
                                      ],
                                      pointers: <GaugePointer>[
                                        NeedlePointer(value: delta, enableAnimation: true),
                                      ],
                                      ranges: <GaugeRange>[
                                        GaugeRange(startValue: 0, endValue: 80, color: Colors.green, startWidth: 10, endWidth: 10),
                                        GaugeRange(startValue: 80, endValue: 180, color: Colors.orange, startWidth: 10, endWidth: 10),
                                        GaugeRange(startValue: 180, endValue: 250, color: Colors.red, startWidth: 10, endWidth: 10)
                                      ])
                                ]),
                              ),
                              const Text("DELTA", style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          Container(
              margin: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: Column(
                children: [
                  const Text("HTO Temperature Dyeing 2", style: TextStyle(fontSize: 18)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 2.0, bottom: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 300,
                                child: SfRadialGauge(enableLoadingAnimation: true, animationDuration: 2500, axes: <RadialAxis>[
                                  RadialAxis(
                                      minimum: 0,
                                      maximum: 250,
                                      interval: 25,
                                      axisLabelStyle: const GaugeTextStyle(fontSize: 17),
                                      annotations: <GaugeAnnotation>[
                                        GaugeAnnotation(
                                          widget: Text(htoinlet.toString(), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                                          angle: 90,
                                          positionFactor: 0.5,
                                        )
                                      ],
                                      pointers: <GaugePointer>[
                                        NeedlePointer(value: htoinlet, enableAnimation: true),
                                      ],
                                      ranges: <GaugeRange>[
                                        GaugeRange(startValue: 0, endValue: 80, color: Colors.green, startWidth: 10, endWidth: 10),
                                        GaugeRange(startValue: 80, endValue: 180, color: Colors.orange, startWidth: 10, endWidth: 10),
                                        GaugeRange(startValue: 180, endValue: 250, color: Colors.red, startWidth: 10, endWidth: 10)
                                      ])
                                ]),
                              ),
                              const Text("INLET", style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 2.0, bottom: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 300,
                                child: SfRadialGauge(enableLoadingAnimation: true, animationDuration: 2500, axes: <RadialAxis>[
                                  RadialAxis(
                                      minimum: 0,
                                      maximum: 250,
                                      interval: 25,
                                      axisLabelStyle: const GaugeTextStyle(fontSize: 17),
                                      annotations: <GaugeAnnotation>[
                                        GaugeAnnotation(
                                          widget: Text(htooutlet.toString(), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                                          angle: 90,
                                          positionFactor: 0.5,
                                        )
                                      ],
                                      pointers: <GaugePointer>[
                                        NeedlePointer(value: htooutlet, enableAnimation: true),
                                      ],
                                      ranges: <GaugeRange>[
                                        GaugeRange(startValue: 0, endValue: 80, color: Colors.green, startWidth: 10, endWidth: 10),
                                        GaugeRange(startValue: 80, endValue: 180, color: Colors.orange, startWidth: 10, endWidth: 10),
                                        GaugeRange(startValue: 180, endValue: 250, color: Colors.red, startWidth: 10, endWidth: 10)
                                      ])
                                ]),
                              ),
                              const Text("OUTLET", style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 2.0, left: 2.0, bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 300,
                                child: SfRadialGauge(enableLoadingAnimation: true, animationDuration: 2500, axes: <RadialAxis>[
                                  RadialAxis(
                                      minimum: 0,
                                      maximum: 250,
                                      interval: 25,
                                      axisLabelStyle: const GaugeTextStyle(fontSize: 17),
                                      annotations: <GaugeAnnotation>[
                                        GaugeAnnotation(
                                          widget: Text(htodelta.toString(), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                                          angle: 90,
                                          positionFactor: 0.5,
                                        )
                                      ],
                                      pointers: <GaugePointer>[
                                        NeedlePointer(value: htodelta, enableAnimation: true),
                                      ],
                                      ranges: <GaugeRange>[
                                        GaugeRange(startValue: 0, endValue: 80, color: Colors.green, startWidth: 10, endWidth: 10),
                                        GaugeRange(startValue: 80, endValue: 180, color: Colors.orange, startWidth: 10, endWidth: 10),
                                        GaugeRange(startValue: 180, endValue: 250, color: Colors.red, startWidth: 10, endWidth: 10)
                                      ])
                                ]),
                              ),
                              const Text("DELTA", style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
