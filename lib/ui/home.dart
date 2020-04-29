import 'package:flutter/material.dart';
import 'todoscreen.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("TO-DO List"),
        backgroundColor: Colors.black54,
      ),
      body: new ToDoScreen(),
    );
  }
}
