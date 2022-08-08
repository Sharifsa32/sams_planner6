import 'package:flutter/material.dart';
import 'package:sams_planner6/list_screen.dart';

class LaterClass extends StatelessWidget {
  const LaterClass({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Sam's Planner",
      home: ListScreen("Later"),
    );
  }
}
