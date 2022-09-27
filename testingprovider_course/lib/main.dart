import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BreadCrumbProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: const HomePage(),
        routes: {
          '/new': (context) => const NewBreadCrumbWidget(),
        },
      ),
    ),
  );
}

class BreadCrumb {
  bool isActive;
  final String name;
  final String uuid;

  BreadCrumb({
    required this.isActive,
    required this.name,
  }) : uuid = const Uuid().v4();

  void activate() {
    isActive = true;
  }

  @override
  bool operator ==(covariant BreadCrumb other) => uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  String get title => name + (isActive ? '>' : '');
}

class BreadCrumbProvider extends ChangeNotifier {
  final List<BreadCrumb> _items = [];

  UnmodifiableListView<BreadCrumb> get items => UnmodifiableListView(_items);

  void add(BreadCrumb breadCrumb) {
    for (final item in _items) {
      item.activate();
    }

    _items.add(breadCrumb);

    notifyListeners();
  }

  void reset() {
    _items.clear();
    notifyListeners();
  }
}

// typedef OnBreadCrumbTapped = void Function(BreadCrumb);

class BreadCrumbsWidget extends StatelessWidget {
  // final OnBreadCrumbTapped onTapped;
  final UnmodifiableListView<BreadCrumb> breadCrumbs;
  const BreadCrumbsWidget({super.key, required this.breadCrumbs});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: breadCrumbs.map((breadCrumb) {
        return GestureDetector(
          onTap: () {
            // onTapped(breadCrumb);
          },
          child: Text(
            breadCrumb.title,
            style: TextStyle(
              color: breadCrumb.isActive ? Colors.blue : Colors.amber,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  //When outside build function use provider of to show that it shouldn't be used like that

  @override
  Widget build(BuildContext context) {
    //context.select<BreadCrumbProvider>((value) => value.aspect1); - gives back aspect1 and if changes then it rebuilds
    //usually use select in build functions and not in callbacks
    //context.watch also here, don't use in callbacks
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home page'),
      ),
      body: Column(
        children: [
          Consumer<BreadCrumbProvider>(
            builder: (context, value, child) {
              return BreadCrumbsWidget(breadCrumbs: value.items);
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/new');
            },
            child: const Text('Add new bread crumb'),
          ),
          TextButton(
            onPressed: () {
              //This read shouldn't be in build function, it should be where you wanna communicate something with the provider
              //Usually its in a callback
              //read uses provider of
              //does not listen
              context.read<BreadCrumbProvider>().reset();
            },
            child: const Text('Reset'),
          )
        ],
      ),
    );
  }
}

class NewBreadCrumbWidget extends StatefulWidget {
  const NewBreadCrumbWidget({super.key});

  @override
  State<NewBreadCrumbWidget> createState() => _NewBreadCrumbWidgetState();
}

class _NewBreadCrumbWidgetState extends State<NewBreadCrumbWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new bread crum"),
      ),
      body: Column(children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
              hintText: 'Enter a new bread crumb here...'),
        ),
        TextButton(
          onPressed: () {
            final text = _controller.text;
            if (text.isNotEmpty) {
              final breadCrumb = BreadCrumb(
                isActive: false,
                name: text,
              );

              context.read<BreadCrumbProvider>().add(breadCrumb);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ]),
    );
  }
}
