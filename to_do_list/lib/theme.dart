import 'package:flutter/material.dart';

class LifeListTheme with ChangeNotifier {
  static const Color themeBlue = Color.fromRGBO(93, 180, 242, 1);
  static const Color themeDarkBlue = Color.fromRGBO(9, 55, 88, 1);

  static ThemeData get myTheme {
    return ThemeData(
      inputDecorationTheme: const InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: themeDarkBlue), // Color of the line when focused
        ),
      ),
      splashColor: themeDarkBlue,
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              overlayColor: MaterialStateProperty.all<Color>(themeBlue),
              textStyle: MaterialStateProperty.resolveWith<TextStyle>(
                  (Set<MaterialState> states) {
                // Define the base TextStyle
                return const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                );
              }),
              foregroundColor:
                  MaterialStateProperty.all<Color>(themeDarkBlue))),
      checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all<Color>(themeDarkBlue),
          overlayColor: MaterialStateProperty.all<Color>(themeBlue)),
      tabBarTheme: TabBarTheme(
          overlayColor: MaterialStateProperty.all<Color>(themeBlue),
          splashFactory: NoSplash.splashFactory,
          indicatorColor: themeDarkBlue,
          unselectedLabelStyle: const TextStyle(fontSize: 25.0),
          labelStyle: const TextStyle(color: themeDarkBlue, fontSize: 30.0)),
      colorScheme: const ColorScheme.light(
          background: Color.fromRGBO(93, 180, 242, 100)),
      appBarTheme: const AppBarTheme(
        backgroundColor: themeBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(0),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        // splashColor: Colors.purple.shade400,
        splashColor: Color.fromRGBO(93, 180, 242, 1),
        backgroundColor: Color.fromRGBO(9, 55, 88, 1),
      ),
    );
  }
}

//! ///////////////////////////////////CUSTOM CLASSES//////////////////////////////////////////
class TaskCardContainer extends StatelessWidget {
  const TaskCardContainer({this.isLarge = false, required this.child, Key? key})
      : super(key: key);

  final Widget child;
  final bool isLarge;
  @override
  Widget build(BuildContext context) {
    Container taskCard = Container(
      margin: const EdgeInsets.all(8),
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
