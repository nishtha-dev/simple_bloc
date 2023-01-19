import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    late final Bloc bloc;
    return Scaffold();
  }
}

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonAction extends LoadAction {
  final PersonUrl url;
  const LoadPersonAction({required this.url}) : super();
}
enum PersonUrl{
  person1,
  person2,
}

class Person{
  final String name; 
  final int age;

  Person(this.name, this.age);
  Person.fromJson(Map<String, dynamic> json) : name= json["name"] as String, age= json["age"] as int;
}

extension UrlString on PersonUrl{
  String get urlString{
    switch (this){
      case PersonUrl.person1 :
        return 'http://27.0.0.1:5500/api/person1.json';
      case PersonUrl.person2 : 
      return 'http://27.0.0.1:5500/api/person2.json';
    }
  }
}



