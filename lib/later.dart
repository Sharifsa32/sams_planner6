import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams_planner6/main.dart';


class LaterClass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sam's Planner",
      home: Later(),
    );
  }
}

class Later extends StatefulWidget {
  @override
  State<Later> createState() => _Later();
}

class _Later extends State<Later> {
  String title = "Later Tasks";

  final Stream<QuerySnapshot> _usersStream =
  FirebaseFirestore.instance.collection('task_details').where("is_later", isEqualTo: true)
      .where("is_archived", isEqualTo: false).snapshots();

  @override
  void initState() {
    super.initState();
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
      case "unarchive":
        X.update({"is_archived": !isIt});
        break;
      case "later":
        X.update({"is_later": !isIt});
        break;
      case "delete":
        X.delete();
    }

  }


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
                MaterialPageRoute(builder: (context) => MyApp()),
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
                                  actionTask(document.id, data["is_archived"], "unarchive");
                                },
                                child: const Text("Archived")),
                            ElevatedButton(
                                onPressed: () {
                                  actionTask(document.id,
                                      data["is_later"], "later");
                                },
                                child: const Text("Now")),
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
    );
  }
}
