var express = require('express');
var app = express();
var bodyParser = require('body-parser');
var admin = require("firebase-admin");

var urlencodedParser = bodyParser.urlencoded({ extended: false })
var serviceAccount = require("./attendance-ede17-firebase-adminsdk-x25in-f45c03857e");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://attendance-ede17.firebaseio.com"
});

app.post('/adduser', urlencodedParser, function(req, res){

    admin.auth().createUser({
        email: req.body.email,
        emailVerified: false,
        password: req.body.password,
        disabled: false,
        uid: req.body.rollno 
    })
    .then(function(userRecord)
    {
        admin.firestore().collection('users').doc(req.body.rollno).set({
                'email': req.body.email,
                'role': req.body.role
            }).then(function(doc){

                if(req.body.role == 'student'){
                    admin.firestore().collection('attendance').doc(req.body.rollno).set({

                    }).then(function(doc1){
                        res.status(201).send("created");
                    }).catch(function(error)
                    {
                        console.log(error);
                        res.status(401).send("Data Not added to attendance table");
                    });
                }else{
                    res.status(201).send("created");
                }
            }).catch(function(error)
            {
                console.log(error);
                res.status(401).send("Data not added to user table");
            });
    })
    .catch(function(error)
    {
        console.log(error);
        res.status(401).send("user already exists");
    });
});

app.post('/addcourse', urlencodedParser, function(req, res){
    admin.firestore().collection('courses').doc(req.body.code).set({
        'name': req.body.name,
        'staff': req.body.staff,
        'students': []
    }).then(function(doc){
        res.status(201).send("created");
    }).catch(function(error)
    {
        res.status(401).send("Data not added to courses table");
    });
});

app.post('/enrollment', urlencodedParser, function(req, res){
    admin.firestore().collection('courses').doc(req.body.code).update({
        'students': admin.firestore.FieldValue.arrayUnion(req.body.rollno)
    }).then(function(doc){
        var obj = {};
        obj[req.body.code] = {
            'attendance':[]
        }
        admin.firestore().collection('attendance').doc(req.body.rollno).update(obj).then(function(doc){
            res.status(201).send("created");
        }).catch(function(error)
        {
            res.status(401).send("Data not added to attendance table");
        });
    }).catch(function(error)
    {
        res.status(401).send("Data not added to courses table");
    });
});

app.listen(3000);