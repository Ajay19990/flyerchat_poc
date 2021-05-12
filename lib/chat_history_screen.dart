import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flyerchat_poc/chat_screen.dart';
import 'package:flyerchat_poc/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({Key? key}) : super(key: key);

  @override
  _ChatHistoryScreenState createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: TabBar(
            onTap: (index) {
              // Tab index when user select it, it start from zero
            },
            tabs: [
              Tab(icon: Icon(Icons.verified_user)),
              Tab(icon: Icon(Icons.chat)),
            ],
          ),
        ),
        body: _getBody(),
      ),
    );
  }

  Widget _getBody() {
    return TabBarView(
      children: [
        _getUserList(),
        _getChatList(),
      ],
    );
  }

  Widget _getUserList() {
    return StreamBuilder<List<types.User>>(
      stream: FirebaseChatCore.instance.users(),
      initialData: [],
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error occurred'));
        }

        var data = snapshot.data as List<types.User>;

        final selfUid = FirebaseAuth.instance.currentUser!.uid;
        data = data.where((u) => selfUid != u.id).toList();

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (_, index) {
            final user = data[index];
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
              ),
              padding: EdgeInsets.all(10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigoAccent,
                ),
                title: Text(user.firstName! + ' ' + user.lastName!),
                onTap: () async {
                  final room =
                      await FirebaseChatCore.instance.createRoom(data[index]);
                  final route = MaterialPageRoute(
                    builder: (_) => ChatScreen(roomId: room.id),
                  );
                  Navigator.push(context, route);
                },
              ),
            );
          },
        );
      },
    );
  }

  _getChatList() {
    return StreamBuilder<List<Room>>(
      stream: FirebaseChatCore.instance.rooms(),
      initialData: const [],
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error occurred'));
        }

        final data = snapshot.data as List<Room>;

        return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, index) {
              final room = data[index];
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                ),
                padding: EdgeInsets.all(10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigoAccent,
                  ),
                  title: Text(room.name ?? 'no name'),
                  onTap: () async {
                    final route = MaterialPageRoute(
                      builder: (_) => ChatScreen(roomId: room.id),
                    );
                    Navigator.push(context, route);
                  },
                ),
              );
            });
      },
    );
  }

  // _fetchUsers() async {
  //   CollectionReference users = FirebaseFirestore.instance.collection('users');
  //
  //   final selfUid = FirebaseAuth.instance.currentUser!.uid;
  //
  //   users.get().then((querySnapshot) {
  //     final users = querySnapshot.docs.map((result) {
  //       return ChatListUser(
  //         uid: result.id,
  //         firstName: result['firstName'],
  //         lastName: result['lastName'],
  //       );
  //     }).toList();
  //
  //     this.users = users.where((element) => selfUid != element.uid).toList();
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   });
  // }
}
