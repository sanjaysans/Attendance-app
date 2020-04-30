import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  double _height, _width;
  String _email = '', _password = '';
  GlobalKey<FormState> _key = GlobalKey();
  bool _showPassword = true, _load = false;

  @override
  Widget build(BuildContext context) {

    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
      ),
      body: Container(
        height: _height,
        width: _width,
        padding: EdgeInsets.only(bottom: 5),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              image(),
              welcomeText(),
              loginText(),
              form(),
              forgetPassText(),
              SizedBox(height: _height / 12),
              button(),
            ],
          ),
        ),
      ),
    );
  }

  Widget image(){
    return Container(
      margin: EdgeInsets.only(top: _height / 15.0),
        height: 100.0,
        width: 100.0,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: new Image.asset('assets/images/login.png'),
    );
  }

  Widget welcomeText(){
    return Container(
      margin: EdgeInsets.only(left: _width / 20, top: _height / 100),
      child: Row(
        children: <Widget>[
          Text(
            "Welcome",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 50,
            ),
          ),
        ],
      ),
    );
  }

  Widget loginText() {
    return Container(
      margin: EdgeInsets.only(left: _width / 15.0),
      child: Row(
        children: <Widget>[
          Text(
            "Sign in to your account",
            style: TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget form() {
    return Container(
      margin: EdgeInsets.only(
          left: _width / 12.0,
          right: _width / 12.0,
          top: _height / 15.0),
      child: Form(
        key: _key,
        child: Column(
          children: <Widget>[
            emailBox(),
            SizedBox(height: _height / 40.0),
            passwordBox(),
          ],
        ),
      ),
    );
  }

  Widget emailBox(){
   return Material(
      borderRadius: BorderRadius.circular(30.0),
      elevation: 10,
      child:TextFormField(
        onSaved: (input) => _email = input,
        keyboardType: TextInputType.emailAddress,
        cursorColor: Colors.redAccent,
        obscureText: false,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.email, color: Colors.redAccent, size: 20),
          hintText: "Email ID",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget passwordBox(){
   return Material(
      borderRadius: BorderRadius.circular(30.0),
      elevation: 10,
      child:TextFormField(
        onSaved: (input) => _password = input,
        keyboardType: TextInputType.visiblePassword,
        cursorColor: Colors.redAccent,
        obscureText: _showPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock, color: Colors.redAccent, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.remove_red_eye,
              color: this._showPassword ? Colors.grey : Colors.redAccent,
            ),
            onPressed: () {
              setState(() => this._showPassword = !this._showPassword);
            },
          ),
          hintText: "Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none
          ),
        ),
      ),
    );
  }

  Widget forgetPassText() {
    return Container(
      margin: EdgeInsets.only(top: _height / 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Forgot your password?",
            style: TextStyle(fontWeight: FontWeight.w400,fontSize: 13),
          ),
          SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: () {
              print("Routing");
              Navigator.of(context).pushNamed('forgotpassword');
            },
            child: Text(
              "Recover",
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.redAccent),
            ),
          )
        ],
      ),
    );
  }

  Widget button() {
    return !_load ? RaisedButton(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      onPressed: (){
        RegExp regExp = new RegExp(r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$');
        final formstate = _key.currentState;
        formstate.save();
        if(_email == null || _email.isEmpty){
          Scaffold.of(context).showSnackBar(SnackBar(content: Text('Email Cannot be empty')));
        }else if(_password == null || _password.length < 6){
          Scaffold.of(context).showSnackBar(SnackBar(content: Text('Password needs to be atleast six characters')));
        }else if(!regExp.hasMatch(_email)){
          Scaffold.of(context).showSnackBar(SnackBar(content: Text('Enter a Valid Email')));
        }else{
          setState((){_load = true;});
          signIn();
        }
      },
      textColor: Colors.white,
      padding: EdgeInsets.all(0.0),
      child: Container(
        alignment: Alignment.center,
        width: _width/2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          gradient: LinearGradient(
            colors: <Color>[Colors.orange[200], Colors.pinkAccent],
          ),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Text('SIGN IN',style: TextStyle(fontSize: 15)),
      ),
    ): Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<void> signIn() async {    
    try{
      AuthResult result =  await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password);
      FirebaseUser user = result.user;
      
      DocumentSnapshot snapshot = await Firestore.instance.collection('users').document(user.uid).get();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', user.email);
      prefs.setString('role', snapshot['role']);
      print(snapshot['role']);
      prefs.setString('userid', user.uid);
      setState((){_load = false;});
      Navigator.of(context).pushReplacementNamed('home');
    }catch(e){
      setState((){_load = false;});
      print(e.message);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

}