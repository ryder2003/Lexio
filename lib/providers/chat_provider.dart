import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:gsccsg/model/my_user.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

import '../model/chat_message.dart';

class ChatProvider with ChangeNotifier {

  List<ChatMessage> _messages = [];
  final String initialLesson;
  final MyUser user;

  ChatProvider(this.initialLesson, this.user) {
    _initializeChat();

  }

  List<ChatMessage> get messages => _messages;

  Future<void> _initializeChat() async {
    // Send initial lesson to backend
    final uuid = Uuid();
    String randomId = uuid.v4();

    final response = await post(
      Uri.parse('https://gsc-backend-959284675740.asia-south1.run.app/chat'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "userId" : user.id,
        "userInput": initialLesson,
      }),
    );
    // Add initial bot response
    _messages.add(ChatMessage(
      content: jsonDecode(response.body)['response'],
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    _messages.add(ChatMessage(
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    // Get bot response
    final response = await post(
      Uri.parse('https://gsc-backend-959284675740.asia-south1.run.app/chat'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "userId" : user.id,
        "userInput": message,
      }),
    );
    print(response.statusCode);

    print(response.body);

    _messages.add(ChatMessage(
      content: jsonDecode(response.body)['response'],
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}