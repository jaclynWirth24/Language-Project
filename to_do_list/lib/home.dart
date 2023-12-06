import 'package:flutter/material.dart';
import 'package:to_do_list/theme.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const TaskBoard();
  }
}

class TaskBoard extends StatefulWidget {
  const TaskBoard({Key? key}) : super(key: key);
  @override
  State<TaskBoard> createState() => _TaskBoardState();
}

class _TaskBoardState extends State<TaskBoard>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Task> tasks = [];

    //!HARD CODED NUMBERED TASKS TO SIMULATE WHAT IT WILL LOOK LIKE
    for (int i = 1; i <= 2; i++) {
      tasks.add(Task(
        "$i",
        description: "This is description number $i for task numer $i",
      ));
    }
    return Scaffold(
      floatingActionButton: const NewTaskButton(),
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: const Text('Task Board'),
      ),
      body: TaskList(tasks),
    );
  }
}

class TaskList extends StatefulWidget {
  const TaskList(this.tasks, {Key? key}) : super(key: key);
  final List<Task> tasks;
  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList>
    with AutomaticKeepAliveClientMixin {
  final List<Widget> _tasks = [];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    updateTasks();
    return ListView.builder(
      itemBuilder: (context, i) {
        return _tasks[i];
      },
      itemCount: _tasks.length,
    );
  }

  void updateTasks() {
    int start = _tasks.length;
    List<Task> rawTasks = widget.tasks;

    //adds tasks to list if any were added
    for (int i = start; i < rawTasks.length; i++) {
      _tasks.add(TaskCard(rawTasks[i]));
    }

    //Removes tasks if any were removed
    if (start > rawTasks.length) {
      for (int i = 0; i < _tasks.length; i++) {
        TaskCard indexTaskCard = _tasks[i] as TaskCard;
        if (!rawTasks.contains(indexTaskCard.task)) {
          _tasks.remove(indexTaskCard);
        }
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class NewTaskButton extends StatelessWidget {
  const NewTaskButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      label: const Row(children: [Icon(Icons.add), Text("New Task")]),
      onPressed: () => {},
    );
  }
}

class TaskCard extends StatefulWidget {
  const TaskCard(this.task, {Key? key}) : super(key: key);
  final Task task;
  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: .90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaskTitle(widget.task.title),
          TaskDescription(widget.task.description ?? "")
        ],
      ),
    );
  }
}

// typedef
class Task {
  String title;
  String? description;
  Task(this.title, {this.description});

  @override
  String toString() {
    return "title: $title, description: $description\n";
  }
}
