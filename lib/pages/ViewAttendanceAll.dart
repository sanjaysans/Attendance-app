import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewAttendanceAll extends StatelessWidget {
  final String code, uid;
  final List students;
  const ViewAttendanceAll({
    Key key,
    @required this.code,
    @required this.uid,
    @required this.students,
  }) : super(key : key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ViewAttendanceAllScreen(code: code, uid: uid, students: students,),
    );
  }
}

class ViewAttendanceAllScreen extends StatefulWidget {

  final String code, uid;
  final List students;
  const ViewAttendanceAllScreen({
    Key key,
    @required this.code,
    @required this.uid,
    @required this.students,
  }) : super(key : key);

  @override
  _ViewAttendanceAllScreenState createState() => _ViewAttendanceAllScreenState();
}

class _ViewAttendanceAllScreenState extends State<ViewAttendanceAllScreen> {

  var db = Firestore.instance;
  double _height;

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    //_width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.code}'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child:_buildBody(context)
        )
      )
    );
  }

  Widget _buildBody(BuildContext context) {
    try {
      return StreamBuilder(
        stream: db.collection('attendance').where(FieldPath.documentId, whereIn: widget.students).snapshots(),
        builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();

          return DataTable( 
            columnSpacing: 45,
            columns: generateColumns(snapshot.data.documents[0][widget.code]['attendance']),
            rows: snapshot.data.documents.map((element) => generateRows(element.documentID, element[widget.code]['attendance'])).toList(),
          );
        },
      );
    } catch (e) {
      print(e.message);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return Center(child: Text(e.message));
    }
  }

  List<DataColumn> generateColumns(List doc){
    List<String>  heading = new List(doc.length + 1);
    List<String> hrs = new List(doc.length + 1);
    heading[0] = 'Roll Number';
    hrs[0] = '';
    for (var i = 1; i < doc.length + 1; i++) {
      heading[i] = doc[i-1]['date'].toString().split('–')[0];
      hrs[i] = doc[i-1]['hrs'];
    }
    var j = 0;
    return heading.map((data) => 
      DataColumn(
        label: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(data, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              SizedBox(
                height: _height / 80
              ),
              (j == 0) ? 
              Text(hrs[j++], style: TextStyle(color: Colors.white),) :
              Text('Hrs: ${hrs[j++]}', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
            ],
          )
        )
    )).toList();
  }

  DataRow generateRows(String docId, List attendance){
    List<String> row = List(attendance.length + 1);
    row[0] = docId;
    for (var i = 1; i < attendance.length + 1; i++) {
      if(attendance[i-1]['attendance']){
        row[i] = '1';
      }else{
        row[i] = '0';
      }
    }
    return DataRow(
      cells: row.map((data) => generateCells(data)).toList(),
    );
  }

  DataCell generateCells(String data){
    return DataCell(
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          (data == '1') ? Icon(Icons.check, color: Colors.redAccent) :
            (data == '0') ? Icon(Icons.close, color: Colors.grey) : Text(data),
        ],
      )
    );
  }

}