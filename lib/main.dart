import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flyerchat_poc/chat_history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Wait for Firebase to initialize and set `_initialized` state to true
    await Firebase.initializeApp();
  } catch (e) {
    print('error in initialising: $e');
  }
  runApp(App());
}

class App extends StatefulWidget {
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  String? uid;

  @override
  void initState() {
    super.initState();
    _setupSharedPreferences();
  }

  _setupSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid');
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null || uid == '') {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatHistoryScreen(),
    );
  }
}
