import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class InheritedTasks extends InheritedWidget {
  InheritedTasks(this.allTasks, {required Widget child, Key? key})
      : super(key: key, child: child);

  final List<List<Task>> allTasks;

  Function swapTabs = (bool done, var allTasks, Task task) {
    if (done) {
      allTasks[0].remove(task);
      allTasks[1].add(task);
    } else {
      allTasks[1].remove(task);
      allTasks[0].add(task);
    }
  };

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
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Task").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: Text("Loading..."));

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
    var allTasks = InheritedTasks.of(context)!.allTasks;
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
                  setState(InheritedTasks.of(context)!
                      .swapTabs(value!, allTasks, widget.task));
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
