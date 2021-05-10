import 'package:flutter/material.dart';
import 'package:flyerchat_poc/models/chat_list_user.dart';

class ChatScreen extends StatefulWidget {
  final ChatListUser chatListUser;

  const ChatScreen({
    Key? key,
    required this.chatListUser,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '${widget.chatListUser.firstName} ${widget.chatListUser.lastName}',
        ),
      ),
      body: _getBody(),
    );
  }

  Widget? _getBody() {}
}
