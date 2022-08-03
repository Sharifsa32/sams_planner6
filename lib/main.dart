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
  late TextEditingController _controller;

  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('task_details').where("is_archived", isEqualTo: false).snapshots();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  addTask(String task) {
    FirebaseFirestore.instance
        .collection("task_details")
        .add({"description": task, "is_done": false, "is_priority": false, "is_archived": false, });
    Navigator.pop(context, 'OK');
  }

  taskStyle(bool isDone, bool isPriority) {
    if (isDone & isPriority) {
      return const TextStyle(
          decoration: TextDecoration.lineThrough, fontWeight: FontWeight.bold);
    } else if (isDone & !isPriority) {
      return const TextStyle(decoration: TextDecoration.lineThrough);
    } else if (!isDone & isPriority) {
      return const TextStyle(fontWeight: FontWeight.bold);
    } else {
      const TextStyle();
    }
  }

  actionTask(dynamic id, bool isIt, String toDo) {
    var X = FirebaseFirestore.instance
        .collection("task_details")
        .doc(id);
    switch(toDo){
      case "prioritize":
        X.update({"is_priority": !isIt});
        break;
      case "archive":
        X.update({"is_archived": !isIt});
        break;
      case "delete":
        X.delete();
    }

    Navigator.pop(context, 'Cancel');

  }

  //void crossTask(){}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
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
                    title: Text(data['description'],
                        style: taskStyle(data["is_done"], data["is_priority"])),
                    onTap: () => FirebaseFirestore.instance
                        .collection("task_details")
                        .doc(document.id)
                        .update({"is_done": !data['is_done']}),
                    onLongPress: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          actions: <Widget>[
                            Column(
                              children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        actionTask(document.id, data["is_priority"], "prioritize");
                                      },
                                      child: const Text("Prioritize")),
                                ElevatedButton(
                                    onPressed: () {
                                      actionTask(document.id, data["is_archived"], "archive");
                                    },
                                    child: const Text("Archive")),
                                ElevatedButton(
                                    onPressed: () {
                                      actionTask(document.id, data["is_priority"], "delete");
                                    },
                                    child: const Text("Delete")),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                })
                .toList()
                .cast(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Add New Task'),
              content: Column(
                children: [
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Task',
                    ),
                  )
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    addTask(_controller.text.toString());
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
