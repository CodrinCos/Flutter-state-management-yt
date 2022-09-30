import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

//this takes out null values from a list
extension CompactMap<T> on Iterable<T?> {
  Iterable<T> compactMap<E>([E? Function(T?)? transform]) =>
      map(transform ?? (e) => e).where((element) => element != null).cast();
}

void testIt() {
  final values = [1, 2, null, 3];
  final nullValues = values.compactMap();
}

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

const url = "https://bit.ly/3x7J5Qt";
const imageHeight = 300.0;

extension Normalize on num {
  num normalized(num selfRangeMin, num selfRangeMax,
          [num normalizedRangeMin = 0.0, num normalizedRangeMax = 1.0]) =>
      (normalizedRangeMax - normalizedRangeMin) *
          ((this - selfRangeMin) / (selfRangeMax - selfRangeMin)) +
      normalizedRangeMin;
}

class HomePage extends HookWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final opacity = useAnimationController(
      duration: const Duration(seconds: 1),
      initialValue: 1,
      upperBound: 1,
      lowerBound: 0,
    );

    final size = useAnimationController(
      duration: const Duration(seconds: 1),
      initialValue: 1.0,
      upperBound: 1.0,
      lowerBound: 0.0,
    );

    final controller = useScrollController();

    useEffect(() {
      controller.addListener(() {
        final newOpacity = max(imageHeight - controller.offset, 0.0);
        final normalized = newOpacity.normalized(0.0, imageHeight).toDouble();

        opacity.value = normalized;
        size.value = normalized;
      });
      return null;
    }, [controller]);

    return Scaffold(
      appBar: AppBar(
        title: const Text("HomePage"),
      ),
      body: Column(children: [
        SizeTransition(
          sizeFactor: size,
          axis: Axis.vertical,
          axisAlignment: -1.0,
          child: FadeTransition(
            opacity: opacity,
            child: Image.network(
              url,
              height: imageHeight,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
              controller: controller,
              itemCount: 100,
              itemBuilder: ((context, index) {
                return ListTile(
                  title: Text('Person ${index + 1}'),
                );
              })),
        )
      ]),
    );
  }
}
