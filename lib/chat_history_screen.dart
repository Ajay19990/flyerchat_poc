import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flyerchat_poc/models/chat_list_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({Key? key}) : super(key: key);

  @override
  _ChatHistoryScreenState createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  List<ChatListUser> users = [];
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
    );
  }

  Widget _getBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return ListView.builder(
        itemCount: users.length,
        itemBuilder: (_, index) {
          final user = users[index];
          return Container(
            padding: EdgeInsets.all(10),
            color: Colors.black26,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigoAccent,
              ),
              title: Text(user.fistName + ' ' + user.lastName),
            ),
          );
        },
      );
    }
  }

  _fetchUsers() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    final selfUid = FirebaseAuth.instance.currentUser!.uid;

    users.get().then((querySnapshot) {
      final users = querySnapshot.docs.map((result) {
        return ChatListUser(
          uid: result.id,
          fistName: result['firstName'],
          lastName: result['lastName'],
        );
      }).toList();

      this.users = users.where((element) => selfUid != element.uid).toList();
      setState(() {
        _isLoading = false;
      });
    });
  }
}
