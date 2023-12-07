import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
    List<Task> tasksDoing = [];
    List<Task> tasksDone = [];

    // //!HARD CODED NUMBERED TASKS TO SIMULATE WHAT IT WILL LOOK LIKE
    // for (int i = 1; i <= 2; i++) {
    //   tasks.add(Task("$i",
    //       description: "This is description number $i for task numer $i",
    //       taskId: "Task$i"));
    // }
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
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Task").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text("Loading...");

          int? size = snapshot.data!.size;
          var docs = snapshot.data!.docs;

          for (var doc in docs) {
            var done = doc.get("done");
            if (widget.done == done) {
              var title = doc.get("title");
              var description = doc.get("description");
              var taskId = doc.get("taskID");
              Task myTask = Task(title,
                  description: description, taskId: taskId, isDone: done);
              _tasks.add(TaskCard(myTask, done, key: ValueKey(taskId)));
            }
          }

          return ReorderableListView.builder(
            clipBehavior: Clip.antiAlias,
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
        });
  }

  @override
  void initState() {
    super.initState();
    List<Task> rawTasks = widget.tasks;
    for (int i = 0; i < rawTasks.length; i++) {
      _tasks
          .add(TaskCard(rawTasks[i], false, key: ValueKey(rawTasks[i].taskId)));
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
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value;
                });
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskTitle(widget.task.title),
                TaskDescription(widget.task.description ?? "")
              ],
            ),
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
  String taskId;
  bool isDone;
  Task(this.title, {this.taskId = '-1', this.description, this.isDone = false});

  @override
  String toString() {
    return "title: $title, description: $description\n";
  }
}
