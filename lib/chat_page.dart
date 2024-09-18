import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice device;
  ChatPage({required this.device});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> messages = [];
  BluetoothCharacteristic? characteristic;

  @override
  void initState() {
    super.initState();
    print("WIDGET DEVICE ------------           ${widget.device}");
    discoverServices();
  }

  void discoverServices() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      print("Service -----    $service");
      service.characteristics.forEach((c) {
        if (c.properties.write && c.properties.notify) {
          setState(() {
            characteristic = c;
          });
        }
      });
    });

    widget.device.state.listen((state) {
      if (state == BluetoothDeviceState.disconnected) {
        Navigator.pop(context);
      }
    });
  }

  void sendMessage(String text) {
    if (characteristic != null) {
      String jsonMessage = jsonEncode({"message": text});
      characteristic!.write(utf8.encode(jsonMessage));
      setState(() {
        messages.add("Me: $text");
      });
    }
  }

  void receiveMessage(List<int> value) {
    String receivedText = utf8.decode(value);
    Map<String, dynamic> json = jsonDecode(receivedText);
    setState(() {
      messages.add("Friend: ${json['message']}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.device.name}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(messages[index]));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(controller: _controller),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
