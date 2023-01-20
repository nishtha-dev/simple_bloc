import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'dart: developers' as devtools show log;

// extension Log on Object{
//   void log() => devtools.log(toString());
// }

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
      home: BlocProvider(
        create: (context) => PersonsBloc(),
        child: const HomePage()),
    );
  }
}

const List<String> names = ["foo", "bar",];

void testIt()
{
  final baz = names[10]; 
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //late final Bloc bloc;
    return Scaffold(
      appBar: AppBar(title: const Text('Bloc Sample'),),
      body: Column(
      children: [
        Row(
          children: [
            TextButton(onPressed: (() {
              context.read<PersonsBloc>().add(const LoadPersonAction(url: PersonUrl.person1),);
            }), child: const Text('Load json #1')),
            TextButton(onPressed: (() {
              context.read<PersonsBloc>().add(const LoadPersonAction(url: PersonUrl.person2));
            }), child: const Text('Load json #2'))
          ],
        ),
        BlocBuilder<PersonsBloc, fetchResult?>(
          buildWhen: (previousResult, currentResult) {
            return previousResult?.person != currentResult?.person;
          },
          builder: ((context, fetchResult) {
            final persons = fetchResult?.person;
            if (persons== null) {
              return SizedBox();
            }
            return Expanded(child: ListView.builder( 
              itemCount: persons.length, 
            itemBuilder: (context, index) {
              final person = persons[index]!;
              return  ListTile(title: Text(person.name),);
            },));
           return Container();
        }))
      ],
      ),
    );
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

  @override
  String toString() => "Person {name: $name, age: $age";
}

extension Subscript<T> on Iterable<T>
{
  T? operator [] (int index){
    length> index ? elementAt(index) : null;
  }
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
//download instance, parse json, and return list of person.
Future<Iterable<Person>> getPersons (String url) => HttpClient().getUrl(Uri.parse(url)).then((req) => req.close()).then((resp) => resp.transform(utf8.decoder).join()).then((str) =>  json.decode(str) as List<dynamic>).then((list) => list.map((e) => Person.fromJson(e)));

@immutable 
class fetchResult{
  final Iterable<Person> person;
  final bool isRetrivedFromcache;

  const fetchResult({required this.person, required this.isRetrivedFromcache});

  @override
  String toString() => 'FetchedResult {isRetrivedFromcache : ${isRetrivedFromcache}, person : ${person}';

   
}

class PersonsBloc extends Bloc<LoadPersonAction, fetchResult?> {
  final Map<PersonUrl, Iterable<Person>> _cache = {};
  PersonsBloc () : super(null) {
    on((event, emit) async{
      final url = event.url;
      if(_cache.containsKey(url))
      {
        final cachedPerson = _cache['url']!;
        final result = fetchResult(person: cachedPerson, isRetrivedFromcache: true);
        emit(result);

      }
      else{
        final person = await getPersons(url.urlString);
        _cache[url] = person;
        final result = fetchResult(person: person, isRetrivedFromcache: false);
        emit(result);
      }

      } );
    }
  }


