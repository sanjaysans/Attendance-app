import 'package:Attendance/pages/forgotpassword.dart';
import 'package:Attendance/pages/home.dart';
import 'package:Attendance/pages/login.dart';
import 'package:Attendance/pages/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Attendance",
      theme: ThemeData(primaryColor: Colors.redAccent),
      routes: <String, WidgetBuilder>{
        'splashscreen': (BuildContext context) =>  SplashScreen(),
        'login': (BuildContext context) =>  LoginPage(),
        'forgotpassword': (BuildContext context) => ForgotPassword(),
        'home': (BuildContext context) => Home(),
      },
      initialRoute: 'splashscreen',
    );
  }
}


