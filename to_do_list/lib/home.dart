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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButton: const NewTaskButton(),
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          title: const Text('Task Board'),
          bottom: const TabBar(
            tabs: [
              Text("Doing"),
              Text("Done"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TaskList(tasks),
            TaskList(tasks),
          ],
        ),
      ),
    );
  }
}

class TaskList extends StatefulWidget {
  TaskList(this.tasks, {Key? key}) : super(key: key);
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
    // updateTasks();
    return ReorderableListView.builder(
       // clipBehavior: Clip.antiAlias,
       itemBuilder: (context, i) {
         return _tasks[i];
       },
       itemCount: _tasks.length,
       onReorder: (int oldIndex, int newIndex) {
         setState(() {
           int index = newIndex > oldIndex ? newIndex - 1 : newIndex;
           final task = _tasks.removeAt(oldIndex);

           _tasks.insert(index, task);
         });
       },
    );
  }

  @override
  void initState() {
    super.initState();
    List<Task> rawTasks = widget.tasks;
    for (int i = 0; i < rawTasks.length; i++) {
      _tasks.add(TaskCard(rawTasks[i]));
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
      child: TaskCardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskTitle(widget.task.title),
            TaskDescription(widget.task.description ?? "")
          ],
        ),
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
