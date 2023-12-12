import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/theme.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<List<Task>> allTasks;
  bool taskWindowUp = false;
  @override
  void initState() {
    super.initState();
    allTasks = List.empty(growable: true);
    allTasks.add(List.empty(growable: true));
    allTasks.add(List.empty(growable: true));
  }

  @override
  Widget build(BuildContext context) {
    return InheritedTasks(
        allTasks, swapTabs, toggleCreateTaskWindow, taskWindowUp,
        child: const TaskBoard());
  }

  void swapTabs(bool done, Task myTask) {
    setState(() {
      String taskNo = myTask.id!;
      final task = <String, dynamic>{
        "title": myTask.title,
        "description": myTask.description,
        "done": !myTask.isDone,
        "taskID": myTask.taskId,
      };
      FirebaseFirestore.instance.collection("Task").doc(taskNo).set(task);
      myTask.isDone = !myTask.isDone;
    });
  }

  void toggleCreateTaskWindow() {
    setState(() {
      taskWindowUp = !taskWindowUp;
    });
  }
}

class InheritedTasks extends InheritedWidget {
  const InheritedTasks(this.allTasks, this.swapTabs, this.toggleCreateTaskWindow,
      this.taskWindowUp,
      {required Widget child, Key? key})
      : super(key: key, child: child);

  final List<List<Task>> allTasks;
  final bool taskWindowUp;
  final void Function(bool, Task) swapTabs;
  final void Function() toggleCreateTaskWindow;

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
  const TaskList(this.tasks, this.done, {Key? key}) : super(key: key);
  final List<Task> tasks;
  final bool done;
  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList>
    with AutomaticKeepAliveClientMixin {
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = [];
  }

  Future<List<Task>> fetchTasks() async {
    var snapshot = await FirebaseFirestore.instance.collection("Task").get();
    var docs = snapshot.docs;

    return docs
        .map((doc) {
          var done = doc.get("done");
          if (widget.done == done) {
            var title = doc.get("title");
            var description = doc.get("description");
            var taskId = doc.get("taskID");
            Task myTask = Task(
              title,
              description: description,
              taskId: taskId,
              isDone: done,
            );
            myTask.id = doc.id;
            return myTask;
          } else {
            return null;
          }
        })
        .where((task) => task != null)
        .cast<Task>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder(
      future: fetchTasks(),
      builder: (context, AsyncSnapshot<List<Task>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SpinKitFadingCircle(
              color: LifeListTheme.themeDarkBlue,
              size: 50.0,
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text(style: TextStyle(fontSize: 30), "Error loading tasks"),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          List<Widget> children = [
            const Center(
              child: Text(style: TextStyle(fontSize: 30), "No tasks available"),
            )
          ];
          var windowUp = InheritedTasks.of(context)!.taskWindowUp;

          if (windowUp) {
            children.add(NewTaskForm(done: widget.done));
          }

          return Stack(children: children);
        } else {
          _tasks = snapshot.data!;
          List<Widget> children = [
            ReorderableListView.builder(
              clipBehavior: Clip.antiAlias,
              itemBuilder: (context, i) {
                return TaskCard(_tasks[i], widget.done,
                    key: ValueKey(_tasks[i].id));
              },
              itemCount: _tasks.length,
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  int index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                  final task = _tasks.removeAt(oldIndex);
                  _tasks.insert(index, task);
                });
              },
            )
          ];
          var windowUp = InheritedTasks.of(context)!.taskWindowUp;

          if (windowUp) {
            children.add(NewTaskForm(done: widget.done));
          }

          return Stack(children: children);
        }
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
      onPressed: InheritedTasks.of(context)!.toggleCreateTaskWindow,
    );
  }
}

class TaskCard extends StatefulWidget {
  const TaskCard(this.task, this.isDone, {Key? key}) : super(key: key);
  final Task task;
  final bool isDone;

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
    InheritedTasks.of(context)!.swapTabs(!val, widget.task);
  }
}

class Task {
  String title;
  String? description;
  String taskId;
  bool isDone;
  String? id;
  Task(this.title, {this.taskId = '-1', this.description, this.isDone = false});

  @override
  String toString() {
    return "title: $title, description: $description\n";
  }
}

class NewTaskForm extends StatefulWidget {
  const NewTaskForm({required this.done, Key? key}) : super(key: key);
  final bool done;
  @override
  State<NewTaskForm> createState() => _NewTaskFormState();
}

class _NewTaskFormState extends State<NewTaskForm> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime date = DateTime.now();
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  void createTask() async {
    String title = _titleController.text;
    String description = _descriptionController.text;

    final task = <String, dynamic>{
      "title": title,
      "description": description,
      "done": widget.done,
      "taskID": "-1",
    };
    FirebaseFirestore.instance.collection("Task").add(task);
    InheritedTasks.of(context)!.toggleCreateTaskWindow();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
            onTap: InheritedTasks.of(context)!.toggleCreateTaskWindow,
            child: const DimmedBackground()),
        Center(
          child: FractionallySizedBox(
            widthFactor: .90,
            heightFactor: .4,
            child: TaskCardContainer(
              child: Material(
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Task Title:"),
                              SizedBox(
                                height: 40,
                                width: 200,
                                child: TextField(
                                  cursorColor: LifeListTheme.themeDarkBlue,
                                  maxLength: 64,
                                  controller: _titleController,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Description:"),
                          SizedBox(
                            // height: 40,
                            // width: 200,
                            child: TextField(
                              cursorColor: LifeListTheme.themeDarkBlue,
                              maxLength: 65,
                              controller: _descriptionController,
                              minLines: 2,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: InheritedTasks.of(context)!
                                .toggleCreateTaskWindow,
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: createTask,
                            child: const Text("Make Task"),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
