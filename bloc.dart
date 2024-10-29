import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

// Events
abstract class CounterEvent {}

class LoadCounter extends CounterEvent {}
class IncrementCounter extends CounterEvent {}
class DecrementCounter extends CounterEvent {}
class ResetCounter extends CounterEvent {}

// States
class CounterState {
  final int count;
  final bool isLoading;
  final String? error;

  String get counterStatus => count >= 0 ? 'Positive' : 'Negative';

  const CounterState({
    required this.count,
    this.isLoading = false,
    this.error,
  });

  CounterState copyWith({
    int? count,
    bool? isLoading,
    String? error,
  }) {
    return CounterState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// BLoC
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  final CounterService _service;

  CounterBloc(this._service) : super(const CounterState(count: 0)) {
    on<LoadCounter>(_onLoadCounter);
    on<IncrementCounter>(_onIncrementCounter);
    on<DecrementCounter>(_onDecrementCounter);
    on<ResetCounter>(_onResetCounter);

    // Load counter when bloc is created
    add(LoadCounter());
  }

  Future<void> _onLoadCounter(
      LoadCounter event,
      Emitter<CounterState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _service.loadSavedCounter();
      emit(state.copyWith(
        count: _service.count,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load counter',
      ));
    }
  }

  Future<void> _onIncrementCounter(
      IncrementCounter event,
      Emitter<CounterState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _service.increment();
      emit(state.copyWith(
        count: _service.count,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to increment counter',
      ));
    }
  }

  Future<void> _onDecrementCounter(
      DecrementCounter event,
      Emitter<CounterState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _service.decrement();
      emit(state.copyWith(
        count: _service.count,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to decrement counter',
      ));
    }
  }

  Future<void> _onResetCounter(
      ResetCounter event,
      Emitter<CounterState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _service.reset();
      emit(state.copyWith(
        count: _service.count,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to reset counter',
      ));
    }
  }
}

// View
class CounterView extends StatelessWidget {
  final String title;

  const CounterView({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: BlocProvider(
        create: (context) => CounterBloc(context.read<CounterService>()),
        child: const CounterContent(),
      ),
    );
  }
}

class CounterContent extends StatelessWidget {
  const CounterContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<CounterBloc, CounterState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const CircularProgressIndicator();
          }

          if (state.error != null) {
            return Text('Error: ${state.error}');
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '${state.count}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'Counter Status: ${state.counterStatus}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.read<CounterBloc>().add(IncrementCounter()),
                child: const Text('Increment'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => context.read<CounterBloc>().add(DecrementCounter()),
                child: const Text('Decrement'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => context.read<CounterBloc>().add(ResetCounter()),
                child: const Text('Reset'),
              ),
            ],
          );
        },
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Create instances
  final repository = CounterRepository(prefs);
  final service = CounterService(repository);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => service),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter BLoC Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CounterView(title: 'Counter with BLoC'),
    );
  }
}