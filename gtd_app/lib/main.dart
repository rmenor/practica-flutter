import 'package:flutter/material.dart';
import 'package:gtd_app/settings.dart';
import 'package:gtd_app/task_list.dart';
import 'package:gtd_domain/gtd_domain.dart';

void main() {
  if (kDebug == true) {
    TaskRepository.shared.addTestData(amount: 140);
  }
  runApp(GTDApp());
}

class GTDApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      home: TaskListPage(),
    );
  }
}
