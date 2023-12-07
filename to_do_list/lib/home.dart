import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<List<Task>> allTasks;

  @override
  void initState() {
    super.initState();
    allTasks = List.empty(growable: true);
    allTasks.add(List.empty(growable: true));
    allTasks.add(List.empty(growable: true));
  }

  @override
  Widget build(BuildContext context) {
    return InheritedTasks(allTasks, swapTabs, child: const TaskBoard());
  }

  void swapTabs(bool done, List<List<Task>> myTasks, Task task) {
    setState(() {
      if (!done) {
        myTasks[0].remove(task);
        myTasks[1].add(task);
      } else {
        myTasks[1].remove(task);
        myTasks[0].add(task);
      }
      task.isDone = !task.isDone;
    });
  }
}

class InheritedTasks extends InheritedWidget {
  InheritedTasks(this.allTasks, this.swapTabs,
      {required Widget child, Key? key})
      : super(key: key, child: child);

  final List<List<Task>> allTasks;

  final void Function(bool, List<List<Task>>, Task) swapTabs;

  @override
  bool updateShouldNotify(covariant InheritedTasks oldWidget) {
    return true;
  }

  static InheritedTasks? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedTasks>();
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
    var allTasks = InheritedTasks.of(context)!.allTasks;
    List<Task> tasksDoing = allTasks[0];
    List<Task> tasksDone = allTasks[1];

    return DefaultTabController(
      length: 2,
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
            TaskList(tasksDoing, false),
            TaskList(tasksDone, true),
          ],
        ),
      ),
    );
  }
}

class TaskList extends StatefulWidget {
  TaskList(this.tasks, this.done, {Key? key}) : super(key: key);
  final List<Task> tasks;
  bool done;
  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList>
    with AutomaticKeepAliveClientMixin {
  final List<Widget> _tasks = [];

  @override
  void initState() {
    super.initState();
    update();
  }

  void update() async {
    await fetch();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> fetch() async {
    var stream = FirebaseFirestore.instance.collection("Task").snapshots();
    // var allTasks = InheritedTasks.of(context)!.allTasks;
    widget.tasks.clear(); // Clear existing tas
    stream.forEach((snapshot) {
      var docs = snapshot.docs;

      for (var doc in docs) {
        var done = doc.get("done");
        if (widget.done == done) {
          var title = doc.get("title");
          var description = doc.get("description");
          var taskId = doc.get("taskID");
          Task myTask = Task(title,
              description: description, taskId: taskId, isDone: done);

          widget.tasks.add(myTask);
          // done ? allTasks[1].add(myTask) : allTasks[0].add(myTask);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // for(var task in widget.tasks) {
    //    _tasks.add(TaskCard(task, task.isDone, key: ValueKey(task.taskId)));
    // }
    return ReorderableListView.builder(
      clipBehavior: Clip.antiAlias,
      itemBuilder: (context, i) {
        return TaskCard(widget.tasks[i], widget.tasks[i].isDone,
            key: ValueKey(widget.tasks[i].taskId));
      },
      itemCount: widget.tasks.length,
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          int index = newIndex > oldIndex ? newIndex - 1 : newIndex;
          final task = widget.tasks.removeAt(oldIndex);

          widget.tasks.insert(index, task);
        });
      },
    );
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
  TaskCard(this.task, this.isDone, {Key? key}) : super(key: key);
  final Task task;
  bool isDone;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool? isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.isDone;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: .90,
      child: TaskCardContainer(
        child: Row(
          children: [
            Checkbox(
              checkColor: Colors.white,
              // fillColor: MaterialStateProperty.resolveWith(getColor),
              value: isChecked,

              onChanged: (val) {
                isChecked = val;
                updateTab(val!);
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TaskTitle(widget.task.title),
                  TaskDescription(widget.task.description ?? "")
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  updateTab(bool val) {
    var allTasks = InheritedTasks.of(context)!.allTasks;
    InheritedTasks.of(context)!.swapTabs(!val, allTasks, widget.task);
  }
}

// typedef
class Task {
  String title;
  String? description;
  String taskId;
  bool isDone;
  Task(this.title, {this.taskId = '-1', this.description, this.isDone = false});

  @override
  String toString() {
    return "title: $title, description: $description\n";
  }
}
