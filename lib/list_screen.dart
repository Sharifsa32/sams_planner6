import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sams_planner6/archive_weekly.dart';
import 'package:sams_planner6/main.dart';
import 'package:sams_planner6/string_extension.dart';
import 'later.dart';

class ListScreen extends StatefulWidget {
  final String pageTitle;

  const ListScreen(this.pageTitle, {Key? key}) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  String title = "Sam's Planner - ";
  late TextEditingController _controller;

  //final Stream<QuerySnapshot> _usersStream;

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

  taskStyle(dynamic data) {
    if (data["is_done"] & data["is_priority"]) {
      return const TextStyle(
          decoration: TextDecoration.lineThrough, fontWeight: FontWeight.bold);
    } else if (data["is_done"] & !data["is_priority"]) {
      return const TextStyle(decoration: TextDecoration.lineThrough);
    } else if (!data["is_done"] & data["is_priority"]) {
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
        Navigator.pop(context);
        break;
      case "done":
        X.update({"is_done": !isIt});
        break;
      case "archive":
        X.update({"is_archived": !isIt});
        Navigator.pop(context);
        break;
      case "later":
        X.update({"is_later": !isIt});
        Navigator.pop(context);
        break;
      case "delete":
        X.delete();
        Navigator.pop(context);
        break;
    }
  }

  //function to build float button if in main screen
  dynamic buildFloatButton(pageTitle) {
    if (pageTitle == "Daily") {
      return FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
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
                    if (_controller.text.toString().trim() != "") {
                      addTask(_controller.text.toString().trim().capitalize());
                    }
                    _controller = TextEditingController();
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    _controller = TextEditingController();
                    Navigator.pop(context, 'Cancel');
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      );
    }
  }

  //function to choose what data to display
  dynamic chooseData(pageTitle) {
    dynamic db = FirebaseFirestore.instance.collection('task_details');
    switch (pageTitle) {
      case "Daily":
        return db
            .where("is_archived", isEqualTo: false)
            .where("is_later", isEqualTo: false)
            .snapshots();
      case "Later":
        return db
            .where("is_archived", isEqualTo: false)
            .where("is_later", isEqualTo: true)
            .snapshots();
      case "Achieved":
        return db
            .where("is_archived", isEqualTo: true)
            .snapshots();
    }
  }

  //function to generate the widgets for the options menu buttons
  optionsMenuWidget(id, isIt, word) {
    String label;
    if (word == "prioritize"){
      label = isIt? "Unprioritize" : "Prioritize";
    } else if (word == "archive"){
      label = isIt? "Unarchive" : "Archive";
    } else {
      label = word;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: 170,
        child: ElevatedButton(
          onPressed: () {
            actionTask(id, isIt, word);
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.teal;
                }
                return Colors.deepPurple; // Use the component's default.
              },
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  //function to return screen items
  Widget navIcon(dynamic icon, dynamic toPage){
    return IconButton(
      icon: Icon(icon),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => toPage),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(title + widget.pageTitle),
        actions: <Widget>[
          navIcon(Icons.home, const MyApp()),
          navIcon(Icons.hourglass_bottom, const LaterClass()),
          navIcon(Icons.done, const ArchiveWeekly()),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chooseData(widget.pageTitle),
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
                  return DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(width: 0.2, color: Color(0xFF000000)),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        data['description'],
                        style: taskStyle(data),
                      ),
                      onTap: () {
                        // add crossing function
                        actionTask(document.id, data["is_done"], "done");
                      },
                      onLongPress: () {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            content: SizedBox(
                              height: 230,
                              width: 100,
                              child: Column(
                                children: [
                                  optionsMenuWidget(document.id,
                                      data["is_priority"], "prioritize"),
                                  optionsMenuWidget(
                                      document.id, data["is_later"], "later"),
                                  optionsMenuWidget(
                                      document.id, data["is_archived"], "archive"),
                                  optionsMenuWidget(
                                      document.id, true, "delete"),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                })
                .toList()
                .cast(),
          );
        },
      ),
      floatingActionButton: buildFloatButton(widget.pageTitle),
    );
  }
}
