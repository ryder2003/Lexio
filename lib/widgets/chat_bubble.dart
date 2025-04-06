import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final Color userColor;
  final Color botColor;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.userColor = Colors.deepPurpleAccent,
    this.botColor = Colors.orangeAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          color: isUser ? userColor : botColor.withOpacity(0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isUser ? Colors.white : Colors.black87,
            fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}