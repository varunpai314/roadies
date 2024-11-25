import 'package:flutter/material.dart';
import 'package:roadies/constant.dart'; // Ensure this file correctly defines the 'ip' constant
import 'package:roadies/pages/group_chat_page.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class SquadPage extends StatefulWidget {
  const SquadPage({super.key});

  @override
  SquadPageState createState() => SquadPageState();
}

class SquadPageState extends State<SquadPage> {
  late WebSocketChannel channel;
  final TextEditingController squadIDController = TextEditingController();
  final TextEditingController userIDController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  String receivedMessages = "";

  @override
  void initState() {
    super.initState();
    connectWebSocket();
  }

  void connectWebSocket() {
    try {
      Uri uri = Uri.parse('ws://$ip:8081/ws');
      channel = IOWebSocketChannel.connect(uri);
      channel.stream.listen(
        (data) {
          setState(() {
            receivedMessages += '$data\n';
          });
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
        onDone: () {
          print('WebSocket closed');
        },
      );
    } catch (e) {
      print('Error connecting to WebSocket: $e');
    }
  }

  void sendLocation() {
    final String squadID = squadIDController.text;
    final String userID = userIDController.text;
    final String location = locationController.text;
    final String data = '$squadID,$userID,$location';
    print(data);
    channel.sink.add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text('Received messages: $receivedMessages'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const GroupChatPage(
                    squadId: 2,
                  )));
        },
        tooltip: 'Send Location',
        child: const Icon(Icons.send),
      ),
    );
  }

  @override
  void dispose() {
    squadIDController.dispose();
    userIDController.dispose();
    locationController.dispose();
    channel.sink.close(status.goingAway);
    super.dispose();
  }
}
