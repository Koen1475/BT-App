import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Add this import for file picking
import 'package:btconnectapp/main.dart';
import 'package:btconnectapp/message.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  final messages = <Message>[];

  @override
  void initState() {
    super.initState();
    allBluetooth.listenForData.listen((event) {
      messages.add(Message(
        message: event.toString(),
        isMe: false,
      ));
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  void _sendFile(Uint8List fileBytes) {
    allBluetooth.sendMessage(fileBytes as String);
    // You might want to display some indication that the file is being sent
  }

  Future<void> _pickAndSendFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Uint8List fileBytes = result.files.single.bytes!;
      _sendFile(fileBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 26, 26),
        actions: [
          ElevatedButton(
            onPressed: () {
              allBluetooth.closeConnection();
            },
            child: const Text("CLOSE"),
          ),
          ElevatedButton(
            onPressed: _pickAndSendFile,
            child: const Text("SEND FILE"),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChatBubble(
                    clipper: ChatBubbleClipper4(
                      type: message.isMe
                          ? BubbleType.sendBubble
                          : BubbleType.receiverBubble,
                    ),
                    alignment:
                        message.isMe ? Alignment.topRight : Alignment.topLeft,
                    child: Text(
                      message.message,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 26, 26, 26),
                    enabledBorder: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  final message = messageController.text;
                  allBluetooth.sendMessage(message);
                  messageController.clear();
                  messages.add(
                    Message(
                      message: message,
                      isMe: true,
                    ),
                  );
                  setState(() {});
                },
                icon: const Icon(Icons.send),
                color: Colors.blue,
              )
            ],
          )
        ],
      ),
    );
  }
}
