import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ForgotPasswordScreen(),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  double _height, _width;
  String _email = '';
  bool _load = false;

  GlobalKey<FormState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {

    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Container(
        height: _height,
        width: _width,
        padding: EdgeInsets.only(bottom: 5),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              image(),
              form(),
              SizedBox(height: _height / 12),
              button()
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
        }else if(!regExp.hasMatch(_email)){
          Scaffold.of(context).showSnackBar(SnackBar(content: Text('Enter a Valid Email')));
        }else{
          setState((){_load = true;});
          resetPassword();
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
        child: Text('Reset Password',style: TextStyle(fontSize: 15)),
      ),
    ) : Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<void> resetPassword() async {
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
      setState((){_load = false;});
      print("Sending email");
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Reset password link sent to registered email')));
    }catch(e){
      setState((){_load = false;});
      print(e.message);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

}