import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sam's Planner",
      home: AddData(),
    );
  }
}

class AddData extends StatefulWidget {
  @override
  State<AddData> createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {
  bool isChecked = false;
  String title = "Sam's Planner - Daily";

  final Stream<QuerySnapshot> _usersStream =
  FirebaseFirestore.instance.collection('task_details').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data!.docs
                .map((DocumentSnapshot document) {
              Map<String, dynamic> data =
              document.data()! as Map<String, dynamic>;
              return ListTile(
                  title: Text(data['description'], style: (!data['is_done']) ?
                  const TextStyle(decoration: TextDecoration.lineThrough)
                      : const TextStyle(),),
                  //onTap:,
                //subtitle: Text("$data['is_done']"),
              );
            })
                .toList()
                .cast(),
          );
        },
      ),
    );
  }
}
