import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class CounterModel {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
  }

  void decrement() {
    _count--;
  }

  void reset() {
    _count = 0;
  }
}

class CounterViewModel extends GetxController {
  final CounterModel _model = CounterModel();

  final _counter = 0.obs;

  int get counter => _counter.value;

  String get counterStatus => _counter.value >= 0 ? 'Positive' : 'Negative';

  @override
  void onInit(){
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() {
    _model.increment();
    _counter.value = _model.count;
  }

  void decrement() {
    _model.decrement();
    _counter.value = _model.count;
  }

  void setZero() {
    _model.reset();
    _counter.value = _model.count;
  }
}

class CounterView extends StatelessWidget{
  final String title;

  const CounterView({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: GetBuilder<CounterViewModel>(
          init: CounterViewModel(),
          builder: (viewModel) => CounterContent(viewModel: viewModel),
      )
    );
  }
}

class CounterContent extends StatelessWidget{
  final CounterViewModel viewModel;

  const CounterContent({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'You have pushed the button this many times:',
          ),
          Obx(() => Text(
            '${viewModel.counter}',
            style: Theme.of(context).textTheme.headlineMedium,
          )),
          Obx(() => Text(
            'Counter Status: ${viewModel.counterStatus}',
            style: Theme.of(context).textTheme.titleMedium,
          )),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: viewModel.increment,
            child: const Text('Increment'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: viewModel.decrement,
            child: const Text('Decrement'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: viewModel.setZero,
            child: const Text('Set to Zero'),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter MVVM Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CounterView(title: 'MVVM Counter with GetX'),
    );
  }
}

