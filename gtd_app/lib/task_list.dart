import 'package:flutter/material.dart';
import 'package:gtd_app/done_settings.dart';
import 'package:gtd_app/settings.dart';
import 'package:gtd_app/task_widget.dart';
import 'package:gtd_domain/gtd_domain.dart';
import 'package:mow/mow.dart';
import 'package:gtd_app/drawer.dart';

class TaskListModel extends ModelPair<TaskRepository, DoneSettings> {
  TaskListModel(TaskRepository repo, DoneSettings settings)
      : super(repo, settings);
}

class TaskListPage extends MOWWidget<TaskListModel> {
  TaskListPage()
      : super(model: TaskListModel(TaskRepository.shared, DoneSettings.shared));

  @override
  MOWState<TaskListModel, TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends MOWState<TaskListModel, TaskListPage> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: GTDDrawer(),
        floatingActionButton:
            FloatingActionButton(onPressed: _newTask, child: Icon(Icons.add)),
        appBar: AppBar(
          title: Text(kAppName),
           backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {});
              },
              controller: _textController, 
              decoration: InputDecoration(
              hintText: 'Escribe la tarea y pulsa +',
                labelText: 'Nueva tarea',
                icon: Icon(Icons.task),
                suffixIcon: _iconButton()
              ),
            ), 
          ),
          Expanded(child: TaskListView())
        ]));
  }

  IconButton? _iconButton() {
    IconButton? ic;

    if (_textController.text.isEmpty) {
      ic = null;
    } else {
      ic = IconButton(
          onPressed: () {
            setState(() {
              _textController.clear();
            });
          },
          icon: Icon(Icons.clear));
    }

    return ic;
  }

  void _newTask() {
    TaskRepository.shared.add(Task.toDo(description: _textController.text));
    _textController.text = '';
  }
}

class TaskListView extends StatelessWidget {
  const TaskListView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return TaskWidget(TaskRepository.shared[index]);
      },
      itemCount: TaskRepository.shared.length,
    );
  }
}
