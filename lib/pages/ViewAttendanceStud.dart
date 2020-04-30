import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewAttendanceStud extends StatelessWidget {
  final String code, uid;
  const ViewAttendanceStud({
    Key key,
    @required this.code,
    @required this.uid,
  }) : super(key : key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ViewAttendanceStudScreen(code: code, uid: uid),
    );
  }
}

class ViewAttendanceStudScreen extends StatefulWidget {

  final String code, uid;
  const ViewAttendanceStudScreen({
    Key key,
    @required this.code,
    @required this.uid,
  }) : super(key : key);

  @override
  _ViewAttendanceStudScreenState createState() => _ViewAttendanceStudScreenState();
}

class _ViewAttendanceStudScreenState extends State<ViewAttendanceStudScreen> {

  var db = Firestore.instance;

  @override
  Widget build(BuildContext context) {
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
        stream: db.collection('attendance').where(FieldPath.documentId, isEqualTo: widget.uid).snapshots(),
        builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          
          List data = snapshot.data.documents[0][widget.code]['attendance'];
          return DataTable( 
            columnSpacing: 45,
            columns: [
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Periods')),
              DataColumn(label: Text('Attendance')),
            ],
            rows: data.map((element) => 
              DataRow(
                cells: [
                  DataCell(Text(element['date'].toString().split('–')[0])),
                  DataCell(Text(element['hrs'])),
                  DataCell(
                    (!element['attendance']) ? Icon(Icons.close, color: Colors.grey) : Icon(Icons.check, color: Colors.redAccent)
                  )
                ]
              )
            ).toList(),
          );
        },
      );
    } catch (e) {
      print(e.message);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return Center(child: Text(e.message));
    }
    
  }

}