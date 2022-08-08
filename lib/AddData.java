
class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  String title = "Sam's Planner - Daily";
  late TextEditingController _controller;

  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('task_details')
      .where("is_archived", isEqualTo: false)
      .where("is_later", isEqualTo: false)
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
    Navigator.of(context, rootNavigator: true).pop();
  }

  //action to toggle priority label for the options menu button
  priorityLabel(id, isPriority) {
    return (isPriority) ? "Unprioritize" : "Prioritize";
  }

  //function to generate the widgets for the options menu buttons
  optionsMenuWidget(id, isIt, word) {
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
          child: Text((word == "prioritize") ? priorityLabel(id, isIt) : word),
        ),
      ),
    );
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
                        style: TextStyle(
                            fontWeight: data['is_priority']
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                      onTap: () {
                        // add crossing function
                        actionTask(document.id, data["is_archived"], "archive");
                      },
                      onLongPress: () {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            content: SizedBox(
                              height: 170,
                              width: 100,
                              child: Column(
                                children: [
                                  optionsMenuWidget(document.id,
                                      data["is_priority"], "prioritize"),
                                  optionsMenuWidget(
                                      document.id, data["is_later"], "later"),
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
                    if (_controller.text.toString().trim() != ""){
                      addTask(_controller.text.toString().trim().capitalize());}
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
      ),
    );
  }
}
