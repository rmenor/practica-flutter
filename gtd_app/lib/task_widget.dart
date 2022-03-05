import 'package:flutter/material.dart';
import 'package:gtd_app/detail_task.dart';
import 'package:gtd_app/done_settings.dart';
import 'package:gtd_domain/gtd_domain.dart';
import 'package:mow/mow.dart';

class TaskWidget extends MOWWidget<Task> {
  TaskWidget(Task task) : super(model: task);

  @override
  MOWState<Task, TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends MOWState<Task, TaskWidget> {
  late BuildContext? _context;

  @override
  Widget build(BuildContext context) {
    _context = context;

    return Dismissible(
      background: DismissibleBackground(),
      secondaryBackground: DismissibleBackground(align: MainAxisAlignment.end),
      onDismissed: (direction) {
        TaskRepository.shared.remove(model);
      },
      key: UniqueKey(),
      child: ListTile(
        onTap: () async {
          final task = await Navigator.of(context).push<Task>(MaterialPageRoute(
              builder: (context) => DetailTask(model: model)));
          // Refrescamos la lista
          setState(() {});
        },
        leading: Checkbox(
          checkColor: Colors.green,
          fillColor:
              MaterialStateProperty.all(Color.fromARGB(255, 202, 230, 241)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onChanged: (bool? newValue) {
            if (newValue != null) {
              if (newValue == true) {
                model.state = TaskState.done;
                _alertDelete();
              } else {
                model.state = TaskState.toDo;
              }
            }
          },
          value: model.state == TaskState.done,
        ),
        title: _descriptionWidget(model.description),
      ),
    );
  }

  void _alertDelete() async {
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
      } else {
        final SnackBar _snackBar = SnackBar(
          content: const Text('Tarea terminada'),
          duration: const Duration(seconds: 5),
        );
        ScaffoldMessenger.of(context).showSnackBar(_snackBar);
      }
    }
  }

  Widget _descriptionWidget(String text) {
    TextStyle? style;
    Color styleDone = Color.fromARGB(255, 202, 230, 241);

    if (DoneSettings.shared[DoneOptions.greyOut] &&
        model.state == TaskState.done) {
      // le metemos un estilo gris
      style = TextStyle(fontStyle: FontStyle.italic, color: Colors.grey);
      styleDone = Color.fromARGB(255, 207, 243, 209);
    }

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Text(
            text,
            style: style,
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: styleDone,
      ),
      height: 50,
    );
  }
}

// Background
class DismissibleBackground extends StatelessWidget {
  late final String _text;
  late final Color _color;
  late final MainAxisAlignment _alignment;

  DismissibleBackground(
      {Key? key,
      String text = 'Delete',
      Color color = Colors.red,
      MainAxisAlignment align = MainAxisAlignment.start})
      : _color = color,
        _text = text,
        _alignment = align,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DeleteButton(text: _text, alignment: _alignment),
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({
    Key? key,
    required String text,
    required MainAxisAlignment alignment,
  })  : _text = text,
        _alignment = alignment,
        super(key: key);

  final String _text;
  final MainAxisAlignment _alignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.delete,
          color: Colors.white70,
        ),
        Text(
          _text,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        SizedBox(
          width: 5.0,
          height: 5.0,
        )
      ],
      mainAxisAlignment: _alignment,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
}
