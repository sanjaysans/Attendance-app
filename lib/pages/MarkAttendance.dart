import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MarkAttendance extends StatelessWidget {

  final String code, uid;
  final List students;
  const MarkAttendance({
    Key key,
    @required this.code,
    @required this.uid,
    @required this.students,
  }) : super(key : key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MarkAttendanceScreen(code: code, uid: uid, students: students,)
    );
  }
}

class MarkAttendanceScreen extends StatefulWidget {

  final String code, uid;
  final List students;
  const MarkAttendanceScreen({
    Key key,
    @required this.code,
    @required this.uid,
    @required this.students,
  }) : super(key : key);

  @override
  _MarkAttendanceScreenState createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {

  List<bool> present;
  double _height, _width;
  GlobalKey<FormState> _key = GlobalKey();
  DateTime now = DateTime.now();
  String formattedDate, hrs = '1';
  var db, batch;
  bool _load = false, _submitted = false;

  @override
  void initState() {
    super.initState();
    try {
      db = Firestore.instance;
      batch = db.batch();
      formattedDate = DateFormat('dd-MM-yyyy – kk:mm').format(now);
      widget.students.sort();
      present = new List(widget.students.length);

      for (var i = 0; i < widget.students.length; i++) {
        present[i] = true;
      }
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
        title: Text('${widget.code}'),
      ),
      body: ListView(
        children: <Widget>[
          form(),
          SizedBox(height: _height / 40.0),
          listHeader(),
          listView(),
          SizedBox(height: _height / 40.0),
          button(),
          SizedBox(height: _height / 40.0),
        ],
      )
    );
  }

  Widget form() {
    return Container(
      margin: EdgeInsets.only(top: _height / 15.0),
      child: Form(
        key: _key,
        child: Column(
          children: <Widget>[
            date(),
            SizedBox(height: _height / 40.0),
            numOfHr(),
          ],
        ),
      ),
    );
  }

  Widget numOfHr(){
    return Container(
      alignment: Alignment.center,
      width: _width,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Number of Hrs:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
            value: hrs,
            underline: Container(), 
            icon: Icon(Icons.arrow_downward, color: Colors.redAccent,),
            iconSize: 24.0, // can be changed, default: 24.0
            iconEnabledColor: Colors.blue,
            items: <String>['1','2','3','4']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text("   $value   "),
              );
            }).toList(),
            onChanged: (String value) {
              setState(() {
                hrs = value;
              });
            },
          ),
          ],
        )
      ),
    );
  }

  Widget date(){
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Date & Time: ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(formattedDate, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget button() {
    return !_load ? Container(
      alignment: Alignment.center,
      width: _width/2,
      child: RaisedButton(
        
        padding:  EdgeInsets.all(0.0),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0)
        ),
        color: Colors.white,
        onPressed: (){
          if(!_submitted){
            _submitted = !_submitted;
            markAttendance();
          }else{
            Scaffold.of(context).showSnackBar(SnackBar(content: Text('Attendance Already Marked!!!!')));
          }
        },
        textColor: Colors.white,
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
          child: Text('Submit',style: TextStyle(fontSize: 15)),
        ),
      ),
    ): Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget listHeader(){
    return Card( 
        child: ListTile(
        title: Text('Roll Number', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Text("Present", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      )
      );
  }
  
  Widget listView() {
    return ListView.builder(
    shrinkWrap: true,
    physics: ClampingScrollPhysics(),
    itemCount: widget.students.length,
    itemBuilder: (context, index) {
      return Card( 
        child: ListTile(
        title: Text(widget.students[index]),
        trailing: present[index] ? new Icon(
          Icons.check,
          color: Colors.redAccent,
          ): new Icon(
          Icons.close,
          color: Colors.grey,
          ),
        onTap:() {
          setState(() {
            present[index] = !present[index];
          });
        },
      )
      );
    },
  );
  }

  void markAttendance() async{
    try {
      setState((){_load = true;});
      DocumentSnapshot data =  await db.collection('attendance').document(widget.students[0]).get();
      int length = data[widget.code]['attendance'].length;
      if(data[widget.code]['attendance'][length-1]['date'].toString() == formattedDate){
        setState((){_load = false;});
        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Attendance Already Marked!!!!')));
      }else{
        for (var i = 0; i < widget.students.length; i++) {
          var obj = [{}];
          obj[0]['date'] = formattedDate;
          obj[0]['hrs'] = hrs;
          obj[0]['attendance'] = present[i];

          await batch.updateData(
            db.collection('attendance').document(widget.students[i]),
            {'${widget.code}.attendance': FieldValue.arrayUnion(obj)}
          );
        }
        await batch.commit();
        setState((){_load = false;});
        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Attendance Marked')));
      }
    } catch (e) {
      setState((){_load = false;});
      print(e.message);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

}