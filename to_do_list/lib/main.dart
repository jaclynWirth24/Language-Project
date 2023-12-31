import 'package:flutter/material.dart';
import 'package:to_do_list/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:to_do_list/theme.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return const Center(
            child: Directionality(
                textDirection: TextDirection.ltr, child: Text("Error")),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: LifeListTheme.myTheme,
            home: const Home(),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return const Center(
          child: Directionality(
              textDirection: TextDirection.ltr,
              child: SpinKitFadingCircle(
                color: LifeListTheme.themeDarkBlue,
                size: 50.0,
              )),
        );
      },
    );
  }
}
