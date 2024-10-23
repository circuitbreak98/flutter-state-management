import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class CounterController extends GetxController{
  int _counter = 0;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose(){
    super.onClose();
  }

  void increment() {
    _counter++;
    update();
  }

  void decrement() {
    _counter--;
    update();
  }

  void setZero() {
    _counter = 0;
    update();
  }
}

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
      home: const MyHomePage(title: 'GetX Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget{
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: GetBuilder(
          init: CounterController(),
          builder: (_) {
            return MyWidget();
          })
    );
  }
}

class MyWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CounterController>(
      builder: (controller) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '${controller._counter}',
                style: Theme
                    .of(context)
                    .textTheme
                    .headlineMedium,
              ),
              ElevatedButton(
                  onPressed: () {
                    controller.increment();
                  },
                  child: Text('increment')),
              ElevatedButton(
                  onPressed: () {
                    controller.decrement();
                  },
                  child: Text('decrement')),
              ElevatedButton(
                  onPressed: () {
                    controller.setZero();
                  },
                  child: Text('set to zero')),
            ],
          ),

        );
      }
       );
      }
  }