import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flyerchat_poc/chat_screen.dart';
import 'package:flyerchat_poc/home_page.dart';
import 'package:flyerchat_poc/models/chat_list_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      appBar: AppBar(
        title: Text('Users'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              FirebaseAuth.instance.signOut();
              final prefs = await SharedPreferences.getInstance();
              prefs.setString('uid', '');
              final route = MaterialPageRoute(builder: (_) => LoginPage());
              Navigator.pushReplacement(context, route);
            },
          ),
        ],
      ),
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
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
            ),
            padding: EdgeInsets.all(10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigoAccent,
              ),
              title: Text(user.firstName + ' ' + user.lastName),
              onTap: () {
                final route = MaterialPageRoute(
                    builder: (_) => ChatScreen(chatListUser: user));
                Navigator.push(context, route);
              },
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
          firstName: result['firstName'],
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
