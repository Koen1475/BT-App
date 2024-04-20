import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:btconnectapp/main.dart';
import 'package:btconnectapp/message.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:permission_handler/permission_handler.dart'; // Import the permission_handler package

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
      if (event != null) {
        messages.add(Message(
          message: event.toString(),
          isMe: false,
        ));
        setState(() {});
      } else {
        // Handle error or connection loss
        // You can implement a retry mechanism here
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  void _sendFile(Uint8List fileBytes) {
    try {
      allBluetooth.sendMessage(fileBytes as String);
    } catch (e) {
      // Handle error
    }
    // You might want to display some indication that the file is being sent
  }

  Future<void> _pickAndSendFile() async {
    // Request permission to access external storage
    final status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission granted, proceed with file picking
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        Uint8List fileBytes = result.files.single.bytes!;
        _sendFile(fileBytes);
      }
    } else {
      // Permission denied
      print('Permission denied to read external storage');
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
                  try {
                    allBluetooth.sendMessage(message);
                    messageController.clear();
                    messages.add(
                      Message(
                        message: message,
                        isMe: true,
                      ),
                    );
                    setState(() {});
                  } catch (e) {
                    // Handle error
                  }
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
