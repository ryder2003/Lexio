import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import '../model/chat_message.dart';

class ChatProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  final String initialLesson;

  ChatProvider(this.initialLesson) {
    _initializeChat();
  }

  List<ChatMessage> get messages => _messages;

  Future<void> _initializeChat() async {
    // Send initial lesson to backend
    final response = await post(
      Uri.parse('https://gsc-backend-959284675740.asia-south1.run.app/chat'),
      body: jsonEncode({"lesson": initialLesson}),
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
      body: jsonEncode({"message": message}),
    );

    _messages.add(ChatMessage(
      content: jsonDecode(response.body)['response'],
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}