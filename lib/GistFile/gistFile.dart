import 'dart:async';
import 'dart:math';
import 'package:flutter_mqtt/model/model.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Broker {
  static final Broker _singleton = Broker._internal();

  factory Broker() {
    return _singleton;
  }

  Broker._internal();

  //Define class variables:
int random = Random().nextInt(100000);
    // print('STB_mqttx_ ${random}' );
  // String broker = 'mq01.sipatex.co.id';
  // int port = 8838;
  // String username = 'it';
  // String password = 'it1234';
  // String clientIdentifier = 'STB_mqttx_ $random';
  MqttServerClient? client;
  StreamSubscription? subscription;
  List<MyModel> gaugeModel = [];

  Future<MqttServerClient> connect() async {
    MqttServerClient client = MqttServerClient.withPort(
      'mq01.sipatex.co.id',
      'SM_mqttx_2019SM',
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

      // print('Received message pay: $payload from topic: ${c[0].topic}>');
      print('Received message: $message');
      var data = payload.split(';')[0].split(',')[0];
      double nilai1 = double.parse(data);
      print("DATA: $data");
      // gaugeModel.add(MyModel(nilai1));
      print(gaugeModel);
      if(gaugeModel.length == 1){
        gaugeModel.removeAt(0);
      }
    });
    client.subscribe("/2022/Majalaya/Dyeing2/temperature_pressure", MqttQos.atMostOnce);
    return client;
  }
}

void onConnected() {
  print('connected');
}

void onDisconnected() {
  print('disconnected');
}

void onSubscribed(String topic) {
  print('subscribed to $topic');
}

void onSubscribeFail(String topic) {
  print('failed to subscribe to $topic');
}

void on() {
  print('disconnected');
}

void pong() {
  print('ping response arrived');
}
