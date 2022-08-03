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

class _AddDataState  extends State<AddData> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Sam's Planner - Daily"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('task_details').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((document) {
              return ListTile(
                title: Center(child: Text(document['description'],
                  style : (isChecked)? const TextStyle(decoration: TextDecoration.lineThrough):const TextStyle(),
                )),
                leading: Checkbox(checkColor: Colors.white,
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value!;
                    });
                  },),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
