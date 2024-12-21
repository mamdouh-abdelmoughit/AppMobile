import 'package:flutter/material.dart';
import 'package:moughit_app/ChatbotService.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final HuggingFaceService _huggingFaceService = HuggingFaceService();
  List<String> _messages = [];

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final userMessage = _controller.text;
      setState(() {
        _messages.add('You: $userMessage');
      });
      _controller.clear();

      final botResponse = await _huggingFaceService.sendMessage(userMessage);
      setState(() {
        _messages.add('Bot: $botResponse');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
