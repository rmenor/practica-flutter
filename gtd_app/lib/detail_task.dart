import 'package:flutter/material.dart';
import 'package:gtd_app/done_settings.dart';
import 'package:gtd_domain/gtd_domain.dart';
import 'package:mow/mow.dart';

class DetailTask extends MOWWidget<Task> {
  DetailTask({required Task model, Key? key}) : super(model: model, key: key);

  @override
  MOWState<Task, DetailTask> createState() => _DetailTaskState();
}

class _DetailTaskState extends MOWState<Task, DetailTask> {
  late BuildContext? _context;
  final _textController = TextEditingController();
  List<bool> isSelected = [true];

  @override
  void initState() {
    super.initState();
    _textController.text = model.description;
    _textController.addListener(_updateModel);
  }

  void _updateModel() {
    model.description = _textController.text;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textController.removeListener(_updateModel);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    String text;

    if (model.state == TaskState.toDo) {
      isSelected[0] = false;
      text = 'Tarea pendiente';
    } else {
      isSelected[0] = true;
      text = 'Tarea terminada';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle'),
        leading: BackButton(onPressed: () => returnToCaller(context)),
      ),
      body: Column(children: [
        Text(model.description, 
        style: TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 35)),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (value) {
              setState(() {});
            },
            controller: _textController,
            decoration: InputDecoration(
                hintText: '',
                labelText: 'Añadir tarea',
                icon: Icon(Icons.task),
                suffixIcon: _iconButton()),
          ),
        ),
        Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ToggleButtons(
          children: <Widget>[
            Icon(Icons.sailing),
          ],
          onPressed: (int index) {
            setState(() {
              isSelected[index] = !isSelected[index];
              if (model.state == TaskState.toDo) {
                model.state = TaskState.done;
                _alertDone();
              } else {
                model.state = TaskState.toDo;
              }
            });
          },
          isSelected: isSelected,
        ),
      ]),
    );
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

  void returnToCaller(BuildContext context) {
    Navigator.of(context).pop<Task?>(model);
  }

  void _alertDone() async {
    if (DoneSettings.shared[DoneOptions.delete]) {
      final shouldDelete = await showDialog<bool>(
          barrierDismissible: false,
          context: _context!,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Borrar la tarea'),
              content: SingleChildScrollView(
                  child: Text('¿De verdad deseas borrarla?')),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text('No')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text('Sí'))
              ],
            );
          });

      // Aquí tenemos la respuesta del usuario
      if (shouldDelete == true) {
        TaskRepository.shared.remove(model);
        Navigator.pop(context);
      }
    } else {
      final SnackBar _snackBar = SnackBar(
        content: const Text('Tarea terminada'),
        duration: const Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(_snackBar);
    }
  }
}
