import 'package:flutter/material.dart';

class LifeListTheme with ChangeNotifier {
  static const Color themeBlue = Color.fromRGBO(13, 71, 161, 1);
  static const Color themeOrange = Color.fromRGBO(161, 102, 13, 1);
  static const Color themePurple = Color.fromRGBO(102, 13, 161, 1);

  static ThemeData get lightTheme {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: themeBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        splashColor: Colors.purple.shade400,
        backgroundColor: themePurple,
      ),
    );
  }
}

//! ///////////////////////////////////CUSTOM CLASSES//////////////////////////////////////////
class TaskCardContainer extends StatelessWidget {
  const TaskCardContainer({this.isLarge = false, required this.child, Key? key})
      : super(key: key);
  const TaskCardContainer.large(
      {this.isLarge = true, required this.child, Key? key})
      : super(key: key);
  final Widget child;
  final bool isLarge;
  @override
  Widget build(BuildContext context) {
    Container taskCard = Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            offset: Offset(1, 5),
            blurRadius: 6,
            spreadRadius: 2,
            // color: LifeListTheme.themeOrange,
          ),
        ],
        color: Colors.grey.shade100,
        border: Border.all(),
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );

    return isLarge
        ? Center(
            child: FractionallySizedBox(
              widthFactor: .9,
              heightFactor: .4,
              child: taskCard,
            ),
          )
        : taskCard;
  }
}

/// Describes the style of the [decription] of a [Task] in a [TaskCard]
class TaskDescription extends StatelessWidget {
  const TaskDescription(this.description, {Key? key}) : super(key: key);
  final String description;
  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: TextStyle(color: Colors.grey.shade900),
    );
  }
}

/// Describes the style of the [title] of a [Task] in a [TaskCard]
class TaskTitle extends StatelessWidget {
  const TaskTitle(this.title, {Key? key}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
    );
  }
}

/// [Container] with all gray background that is transparent to create the effect of a dim.
class DimmedBackground extends StatelessWidget {
  const DimmedBackground({Key? key}) : super(key: key);
  static const dimmedColor = Color.fromARGB(118, 61, 61, 61);
  @override
  Widget build(BuildContext context) {
    return Container(color: dimmedColor);
  }
}
