import 'package:Attendance/pages/MarkAttendance.dart';
import 'package:Attendance/pages/ViewAttendanceAll.dart';
import 'package:Attendance/pages/ViewAttendanceStud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  double _height, _width;
  SharedPreferences prefs;
  bool _load = false;
  String _uid, _role;

  @override
  void initState(){
    super.initState();
    try {
      SharedPreferences.getInstance().then((sharedPrefs) {
        setState(() {
          prefs = sharedPrefs;
          _uid = prefs.getString('userid');
          _role = prefs.getString('role');
        });
      });
    } catch (e) {
      print(e.message);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
    
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: (){
              setState((){_load = true;}); 
              logout();
            },
          )
        ],
      ),
      body: !_load ? checkRole(): Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void logout() async {
    try{
      await FirebaseAuth.instance.signOut();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', null);
      prefs.setString('role', null);
      prefs.setString('userid', null);
      setState((){_load = false;});
      Navigator.of(context).pushReplacementNamed('login');
    }catch(e){
      setState((){_load = false;});
      print(e.message);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Widget checkRole(){
    switch (_role) {
      case 'student':
        return listViewStudents();
        break;
      case 'staff':
        return listViewStaff();
        break;
      case 'admin':
        return listViewAdmin();
        break;
      default:
        return Center(child: Text('Not a valid user role'),);
    }
  }

  Widget listViewStudents() {
    try {
      return new StreamBuilder(
        stream: Firestore.instance.collection('courses').where('students', arrayContains: _uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(
              child: CircularProgressIndicator(),
            );
          return new ListView(
            children: snapshot.data.documents.map((document) {
              return new Card( 
                child:ListTile(
                  title: new Text(document.documentID),
                  subtitle: new Text(document['name']),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ViewAttendanceStud(code: document.documentID, uid: _uid,)));
                  },
                ),
              );
            }).toList(),
          );
        },
      );
    } catch (e) {
      print(e.message);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return Center(child: Text(e.message));
    }
    
  }

  Widget listViewStaff() {
    try {
      return new StreamBuilder(
        stream: Firestore.instance.collection('courses').where('staff', isEqualTo: _uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(
              child: CircularProgressIndicator(),
            );
          return new ListView(
            children: snapshot.data.documents.map((document) {
              return new Card( 
                child:ListTile(
                  title: new Text(document.documentID),
                  subtitle: new Text(document['name']),
                  onTap: (){
                    staffDialog(document.documentID, document['students']);
                  },
                ),
              );
            }).toList(),
          );
        },
      );
    } catch (e) {
      print(e.message);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return Center(child: Text(e.message));
    }
    
  }

  Widget listViewAdmin() {
    try {
      return new StreamBuilder(
        stream: Firestore.instance.collection('courses').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(
              child: CircularProgressIndicator(),
            );
          return new ListView(
            children: snapshot.data.documents.map((document) {
              return new Card( 
                child:ListTile(
                  title: new Text(document.documentID),
                  subtitle: new Text(document['name']),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ViewAttendanceAll(code: document.documentID, uid: _uid, students: document['students'])));
                  },
                ),
              );
            }).toList(),
          );
        },
      );
    } catch (e) {
      print(e.message);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return Center(child: Text(e.message));
    }
    
  }

  staffDialog(String docId, List students){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            content: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      child: Icon(Icons.close),
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    button('View Attendance', docId, students),
                    SizedBox(height: _height / 40.0),
                    button('Mark Attendance', docId, students),
                  ],
                ),
              ],
            ),
          ),
        );
      });
  }

  Widget button(String text, String docId, List students) {
    return RaisedButton(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      onPressed: (){
        if(text == 'View Attendance'){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ViewAttendanceAll(code: docId, uid: _uid, students: students)));
        }else if(text == 'Mark Attendance'){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MarkAttendance(code: docId, uid: _uid, students: students)));
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
        child: Text(text ,style: TextStyle(fontSize: 15)),
      ),
    );
  }

}