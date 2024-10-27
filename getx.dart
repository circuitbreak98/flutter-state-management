import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CounterRepository {
  static const String _counterKey = 'counter_value';
  final SharedPreferences _prefs;

  CounterRepository(this._prefs);

  Future<void> saveCounter(int value) async {
    await _prefs.setInt(_counterKey, value);
  }

  int getCounter() {
    return _prefs.getInt(_counterKey) ?? 0;
  }

  Future<void> clearCounter() async {
    await _prefs.remove(_counterKey);
  }
}


class CounterModel {
  int _count = 0;

  CounterModel([int initialValue = 0]) {
    _count = initialValue;
  }

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

  void setValue(int value) {
    _count = value;
  }
}

class CounterService {
  final CounterRepository _repository;
  final CounterModel _model;

  CounterService(this._repository) : _model = CounterModel(_repository.getCounter());

  int get count => _model.count;

  Future<void> increment() async {
    _model.increment();
    await _repository.saveCounter(_model.count);
  }

  Future<void> decrement() async {
    _model.decrement();
    await _repository.saveCounter(_model.count);
  }

  Future<void> reset() async {
    _model.reset();
    await _repository.saveCounter(_model.count);
  }

  Future<void> loadSavedCounter() async {
    final savedValue = _repository.getCounter();
    _model.setValue(savedValue);
  }
}



class CounterViewModel extends GetxController {
  final CounterService _service;
  final _counter = 0.obs;
  final _isLoading = false.obs;

  CounterViewModel(this._service);

  int get counter => _counter.value;
  bool get isLoading => _isLoading.value;

  String get counterStatus => _counter.value >= 0 ? 'Positive' : 'Negative';

  @override
  void onInit() {
    super.onInit();
    loadCounter();
  }

  Future<void> loadCounter() async {
    _isLoading.value = true;
    try {
      await _service.loadSavedCounter();
      _counter.value = _service.count;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load counter value');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> increment() async {
    _isLoading.value = true;
    try {
      await _service.increment();
      _counter.value = _service.count;
    } catch (e) {
      Get.snackbar('Error', 'Failed to increment counter');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> decrement() async {
    _isLoading.value = true;
    try {
      await _service.decrement();
      _counter.value = _service.count;
    } catch (e) {
      Get.snackbar('Error', 'Failed to decrement counter');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> reset() async {
    _isLoading.value = true;
    try {
      await _service.reset();
      _counter.value = _service.count;
    } catch (e) {
      Get.snackbar('Error', 'Failed to reset counter');
    } finally {
      _isLoading.value = false;
    }
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
          builder: (viewModel) => CounterContent(viewModel: viewModel),
      )
    );
  }
}

class CounterContent extends StatelessWidget {
  final CounterViewModel viewModel;

  const CounterContent({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() {
        if (viewModel.isLoading) {
          return const CircularProgressIndicator();
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${viewModel.counter}',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineMedium,
            ),
            Text(
              'Counter Status: ${viewModel.counterStatus}',
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium,
            ),
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
              onPressed: viewModel.reset,
              child: const Text('Reset'),
            ),
          ],
        );
      }),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Create all instances
  final repository = CounterRepository(prefs);
  final service = CounterService(repository);
  final viewModel = CounterViewModel(service);

  Get.put(viewModel);

  runApp(MyApp());
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

