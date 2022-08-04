import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sams_planner6/archive_weekly.dart';
import 'package:sams_planner6/later.dart';

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

  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('task_details')
      .where("is_archived", isEqualTo: false).where("is_later", isEqualTo: false)
      .snapshots();

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
    FirebaseFirestore.instance.collection("task_details").add({
      "description": task,
      "is_done": false,
      "is_priority": false,
      "is_archived": false,
      "time_created": DateTime.now(),
      "time_completed": DateTime.now(),
      "is_later": false,
    });
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

  crossTask(dynamic id, bool isDone) {
    FirebaseFirestore.instance
        .collection("task_details")
        .doc(id)
        .update({"is_done": !isDone, "time_completed": DateTime.now()});
  }

  actionTask(dynamic id, bool isIt, String toDo) {
    var X = FirebaseFirestore.instance.collection("task_details").doc(id);
    switch (toDo) {
      case "prioritize":
        X.update({"is_priority": !isIt});
        break;
      case "archive":
        X.update({"is_archived": !isIt});
        break;
      case "later":
        X.update({"is_later": !isIt});
        break;
      case "delete":
        X.delete();
    }
    //Navigator.pop(context, 'Cancel');
  }

  //void crossTask(){}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.arrow_circle_down),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ArchiveWeekly()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.hourglass_bottom),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LaterClass()),
              );
            },
          ),
        ],
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
                    onTap: () {
                      // add crossing function
                      crossTask(document.id, data["is_done"]);
                    },
                    onLongPress: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          actions: <Widget>[
                            Column(
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      actionTask(document.id,
                                          data["is_priority"], "prioritize");
                                    },
                                    child: const Text("Prioritize")),
                                ElevatedButton(
                                    onPressed: () {
                                      actionTask(document.id,
                                          data["is_archived"], "archive");
                                    },
                                    child: const Text("Archive")),
                                ElevatedButton(
                                    onPressed: () {
                                      actionTask(document.id,
                                          data["is_later"], "later");
                                    },
                                    child: const Text("later")),
                                ElevatedButton(
                                    onPressed: () {
                                      actionTask(document.id,
                                          data["is_priority"], "delete");
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
              actions: <Widget>[
                Column(
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
                TextButton(
                  onPressed: () {
                    addTask(_controller.text.toString());
                  },
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
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
