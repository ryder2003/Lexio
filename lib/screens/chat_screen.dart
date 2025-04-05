// screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:gsccsg/model/my_user.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatelessWidget {
  final MyUser user;
  final String initialLesson;

  const ChatScreen({super.key, required this.initialLesson, required this.user});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatProvider(initialLesson, user),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dyscalculia Assistant'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, _) {
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.only(bottom: 10),
                    itemCount: provider.messages.length,
                    itemBuilder: (context, index) {
                      final message = provider.messages.reversed.toList()[index];
                      return ChatBubble(
                        message: message.content,
                        isUser: message.isUser,
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Consumer<ChatProvider>(
              builder: (context, provider, _) {
                return SafeArea(
                  child: ChatInput(
                    onSend: (message) => provider.sendMessage(message),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}