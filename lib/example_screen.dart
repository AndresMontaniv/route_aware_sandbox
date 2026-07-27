import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'push_example.dart';

enum StreamConnectionState {
  disconnected,
  listening,
  paused,
}

class ExampleScreenStateData {
  final StreamConnectionState connectionState;
  final int value;

  const ExampleScreenStateData({
    required this.connectionState,
    required this.value,
  });
}

class ExampleScreen extends StatefulWidget {
  static const name = 'example';

  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  StreamSubscription<int>? _subscription;
  final ValueNotifier<ExampleScreenStateData> _stateNotifier = ValueNotifier(
    const ExampleScreenStateData(
      connectionState: StreamConnectionState.disconnected,
      value: 0,
    ),
  );

  @override
  void dispose() {
    _subscription?.cancel();
    _stateNotifier.dispose();
    super.dispose();
  }

  void _startStream() {
    if (_stateNotifier.value.connectionState == StreamConnectionState.listening) return;

    if (_subscription != null && _stateNotifier.value.connectionState == StreamConnectionState.paused) {
      _subscription!.resume();
      _stateNotifier.value = ExampleScreenStateData(
        connectionState: StreamConnectionState.listening,
        value: _stateNotifier.value.value,
      );
      return;
    }

    _subscription?.cancel();
    _stateNotifier.value = const ExampleScreenStateData(
      connectionState: StreamConnectionState.listening,
      value: 0,
    );

    _subscription = Stream.periodic(const Duration(seconds: 1), (count) => count).listen((value) {
      _stateNotifier.value = ExampleScreenStateData(
        connectionState: StreamConnectionState.listening,
        value: value,
      );
    });
  }

  void _pauseStream() {
    if (_stateNotifier.value.connectionState == StreamConnectionState.listening) {
      _subscription?.pause();
      _stateNotifier.value = ExampleScreenStateData(
        connectionState: StreamConnectionState.paused,
        value: _stateNotifier.value.value,
      );
    }
  }

  void _cancelStream() {
    _subscription?.cancel();
    _subscription = null;
    _stateNotifier.value = const ExampleScreenStateData(
      connectionState: StreamConnectionState.disconnected,
      value: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('This is the Example Screen'),
          const SizedBox(height: 30),
          ValueListenableBuilder<ExampleScreenStateData>(
            valueListenable: _stateNotifier,
            builder: (context, stateData, child) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (stateData.connectionState == StreamConnectionState.listening) ...[
                        const CircularProgressIndicator(),
                        const SizedBox(width: 16),
                      ],
                      Text(
                        _getStatusText(stateData.connectionState),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Value: ${stateData.value}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _startStream,
                child: const Text('Start'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _pauseStream,
                child: const Text('Pause'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _cancelStream,
                child: const Text('Cancel'),
              ),
            ],
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              context.pushNamed(PushExampleScreen.name);
            },
            child: const Text('Push Example'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(StreamConnectionState state) {
    switch (state) {
      case StreamConnectionState.disconnected:
        return 'Disconnected';
      case StreamConnectionState.listening:
        return 'Listening...';
      case StreamConnectionState.paused:
        return 'Paused';
    }
  }
}
