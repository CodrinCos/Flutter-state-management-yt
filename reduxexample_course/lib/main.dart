import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const HomePage(),
    ),
  );
}

const apiUrl = "http://127.0.0.1:5500/api/people.json";

@immutable
class Person {
  final String name;
  final int age;

  const Person({
    required this.name,
    required this.age,
  });

  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        age = json['age'] as int;

  @override
  String toString() => 'Peron ($name, $age years old)';
}

//Good thing to be used instead of http package
Future<Iterable<Person>> getPersons() => HttpClient()
    .getUrl(Uri.parse(apiUrl))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));

@immutable
abstract class Action {
  const Action();
}

@immutable
class LoadPeopleAction extends Action {
  const LoadPeopleAction();
}

@immutable
class SuccesfullyFetchedPeopleAction extends Action {
  final Iterable<Person> person;

  const SuccesfullyFetchedPeopleAction({required this.person});
}

@immutable
class FaileToFetchPeopleAction extends Action {
  final Object error;

  const FaileToFetchPeopleAction({required this.error});
}

@immutable
class State {
  final bool isLoading;
  final Iterable<Person>? fetchedPersons;
  final Object? error;

  const State({
    required this.isLoading,
    this.fetchedPersons,
    this.error,
  });

  const State.empty()
      : isLoading = false,
        fetchedPersons = null,
        error = null;
}

State reducer(State oldState, action) {
  if (action is LoadPeopleAction) {
    return const State(
      isLoading: true,
      fetchedPersons: null,
      error: null,
    );
  } else if (action is SuccesfullyFetchedPeopleAction) {
    return State(
      isLoading: false,
      fetchedPersons: action.person,
      error: null,
    );
  } else if (action is FaileToFetchPeopleAction) {
    return State(
      isLoading: false,
      fetchedPersons: oldState.fetchedPersons,
      error: action.error,
    );
  }

  return oldState;
}

void loadPeopleMiddleware(
  Store<State> store,
  action,
  NextDispatcher next,
) {
  if (action is LoadPeopleAction) {
    getPersons().then((persons) {
      store.dispatch(SuccesfullyFetchedPeopleAction(person: persons));
    }).catchError(
      (e) => store.dispatch(FaileToFetchPeopleAction(error: e)),
    );
  }
  next(action);
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = Store(
      reducer,
      initialState: const State.empty(),
      middleware: [loadPeopleMiddleware],
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home page'),
      ),
      body: StoreProvider(
        store: store,
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                store.dispatch(const LoadPeopleAction());
              },
              child: const Text("Load persons"),
            ),
            StoreConnector<State, bool>(
              builder: (context, isLoading) {
                if (isLoading) {
                  return const CircularProgressIndicator();
                } else {
                  return const SizedBox();
                }
              },
              converter: (store) => store.state.isLoading,
            ),
            StoreConnector<State, Iterable<Person>?>(
              builder: (context, people) {
                if (people == null) {
                  return const SizedBox();
                } else {
                  return Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        final person = people.elementAt(index);
                        return ListTile(
                          title: Text(person.toString()),
                        );
                      },
                      itemCount: people.length,
                    ),
                  );
                }
              },
              converter: (store) => store.state.fetchedPersons,
            )
          ],
        ),
      ),
    );
  }
}
