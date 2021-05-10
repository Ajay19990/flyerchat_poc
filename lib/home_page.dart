import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_history_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

enum FormType { login, register }

class _LoginPageState extends State<LoginPage> {
  final _emailFilter = TextEditingController();
  final _passwordFilter = TextEditingController();
  final _firstNameTextController = TextEditingController();
  final _lastNameTextController = TextEditingController();

  String _email = "";
  String _password = "";
  FormType _form = FormType.login;

  _LoginPageState() {
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
  }

  void _emailListen() {
    if (_emailFilter.text.isEmpty) {
      _email = "";
    } else {
      _email = _emailFilter.text;
    }
  }

  void _passwordListen() {
    if (_passwordFilter.text.isEmpty) {
      _password = "";
    } else {
      _password = _passwordFilter.text;
    }
  }

  // Swap in between our two forms, registering and logging in
  void _formChange() async {
    setState(() {
      if (_form == FormType.register) {
        _form = FormType.login;
      } else {
        _form = FormType.register;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildTextFields(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFields() {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: TextField(
              controller: _emailFilter,
              decoration: InputDecoration(labelText: 'Email'),
            ),
          ),
          Container(
            child: TextField(
              controller: _passwordFilter,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ),
          if (_form == FormType.register)
            Container(
              child: TextField(
                controller: _firstNameTextController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
            ),
          if (_form == FormType.register)
            Container(
              child: TextField(
                controller: _lastNameTextController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    if (_form == FormType.login) {
      return Container(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              child: Text('Login'),
              onPressed: _loginPressed,
            ),
            TextButton(
              child: Text('Don\'t have an account? Tap here to register.'),
              onPressed: _formChange,
            ),
          ],
        ),
      );
    } else {
      return Container(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              child: Text('Create an Account'),
              onPressed: _createAccountPressed,
            ),
            TextButton(
              child: Text('Have an account? Click here to login.'),
              onPressed: _formChange,
            )
          ],
        ),
      );
    }
  }

  // These functions can self contain any user auth logic required, they all have access to _email and _password
  void _loginPressed() async {
    print('The user wants to login with $_email and $_password');

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      if (userCredential.user == null) return;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('uid', userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showDialog('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        _showDialog('Wrong password provided for that user.');
      }
    }
  }

  void _createAccountPressed() async {
    print('The user wants to create an account with $_email and $_password');
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      if (userCredential.user == null) return;

      print(
        'created account successful, uid: ${userCredential.user!.uid}',
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('uid', userCredential.user!.uid);

      await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
          avatarUrl: 'https://i.pravatar.cc/300',
          firstName: _firstNameTextController.text,
          id: userCredential.user!.uid,
          lastName: _lastNameTextController.text,
        ),
      );

      final route = MaterialPageRoute(builder: (_) => ChatHistoryScreen());
      Navigator.pushReplacement(context, route);
      print('login successful, uid: ${userCredential.user!.uid}');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showDialog('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        _showDialog('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Hey!'),
          content: Text(message),
        );
      },
    );
  }
}
