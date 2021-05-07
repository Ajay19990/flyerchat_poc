import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

enum FormType { login, register }

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailFilter = TextEditingController();
  final TextEditingController _passwordFilter = TextEditingController();
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
          )
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
  void _loginPressed() {
    print('The user wants to login with $_email and $_password');
  }

  void _createAccountPressed() async {
    print('The user wants to create an account with $_email and $_password');
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      _showDialog(
        'created account successful, uid: ${userCredential.user!.uid}',
      );
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
