import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:invento/screens/landing_page.dart';
import 'package:invento/Helpers/color_loader.dart';
import '../Helpers/component_fields.dart';

class RequestPageAdmin extends StatefulWidget {
  List<String> usersID = [];
  var userData = {};
  String userName;

  @override
  _RequestPageAdminState createState() => _RequestPageAdminState();
}

class _RequestPageAdminState extends State<RequestPageAdmin> {
  Widget buildListItem(BuildContext context, DocumentSnapshot document) {
    return makeListTileRequestAdmin(
      Component(
        componentID: document['Component UUID'],
        context: context,
        userNameRegular: document['User Name'],
        requestUserUID: document['User UUID'],
        collection: 'users',
        componentName: document['Component Name'],
        quantity: document['Quantity'],
        documentId: document.documentID,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserUID();
    getUsers();
  }

  final _firestore = Firestore.instance;

  getUsers() async {
    final QuerySnapshot result =
        await Firestore.instance.collection('users').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    documents.forEach((data) {
      widget.userData[data.documentID] = data['Name'];
    });

    setState(() {
      widget.userName = widget.userData[userUID];
    });
  }

  Future<bool> onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Exit'),
              content: Text('Do you want to exit the app?'),
              actions: <Widget>[
                MaterialButton(
                  color: Colors.black,
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                MaterialButton(
                  color: Colors.black,
                  child: Text('Yes'),
                  onPressed: () {
                    exit(0);
                  },
                )
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('requests').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Column(
                  children: <Widget>[
                    ColorLoader(
                      colors: [
                        Colors.red,
                        Colors.green,
                        Colors.indigo,
                        Colors.pinkAccent,
                        Colors.blue
                      ],
                      duration: Duration(milliseconds: 1200),
                    ),
                  ],
                );
              } else if (snapshot.data.documents.length == 0) {
                return Container(
                  child: Center(
                    child: Text(
                      'No Requests',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return buildListItem(context, snapshot.data.documents[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
