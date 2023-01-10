import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sams_planner6/archive_weekly.dart';
import 'package:sams_planner6/main.dart';
import 'package:sams_planner6/calendar/month_screen.dart';
import 'package:sams_planner6/string_extension.dart';
import 'later.dart';

class WaitingScreen extends StatefulWidget {

  const WaitingScreen({Key? key}) : super(key: key);

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  String title = "Pending";
  late TextEditingController _controller;
  var db = FirebaseFirestore.instance.collection("waiting");


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
    FirebaseFirestore.instance.collection("waiting").add({
      "description": task,
    });
  }

  actionTask(dynamic id, String toDo, String description) {
    var X = db.doc(id);
    switch (toDo) {
      case "Edit":
        Navigator.of(context, rootNavigator: true).pop();
        editTaskForm(description, id);
        break;
      case "Delete":
        X.delete();
        Navigator.of(context, rootNavigator: true).pop();
        break;
    }
  }


  //function to build float button if in main screen
  dynamic buildFloatButton() {
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
                      autofocus: true,
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

  // edit task functions
  void editTask(dynamic id, String controllerText){
    dynamic X = db.doc(id);
    X.update({"description" : controllerText});
  }

  dynamic editTaskForm(String description, dynamic id){
    _controller.text = description;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        actions: <Widget>[
          Column(
            children: [
              TextField(
                controller: _controller,
                autofocus: true,
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
                editTask(id, _controller.text.toString().trim().capitalize());
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
    );}

  //function to generate the widgets for the options menu buttons
  optionsMenuWidget(id, word, description) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: 170,
        child: ElevatedButton(
          onPressed: () {
            actionTask(id, word, description);
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
          child: Text(word),
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
        title: Text(title),
        actions: <Widget>[
          navIcon(Icons.home, const MyApp()),
          navIcon(Icons.watch_later_outlined, const LaterClass()),
          navIcon(Icons.done, const ArchiveWeekly()),
          navIcon(Icons.calendar_month, const MonthClass()),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.snapshots(),
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
                  ),
                  onTap: () {
                    // add crossing function
                    //crossTask(document.id, data["is_done"]);
                    actionTask(document.id, "done", "");
                  },
                  onLongPress: () {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        content: SingleChildScrollView(
                          //height: 230,
                          //width: 100,
                          child: Column(
                            children: [
                              optionsMenuWidget(
                                  document.id, "Edit", data['description']),
                              optionsMenuWidget(
                                  document.id, "Delete", ""),

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
      floatingActionButton: buildFloatButton(),
    );
  }
}
