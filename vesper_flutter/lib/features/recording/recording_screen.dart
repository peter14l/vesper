import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vesper_flutter/features/recording/widgets/recording_orb.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  OrbState _state = OrbState.idle;
  int _seconds = 0;
  Timer? _timer;
  double _amplitude = 0.0;

  void _toggleRecording() {
    setState(() {
      if (_state == OrbState.idle) {
        _state = OrbState.recording;
        _startTimer();
      } else {
        _state = OrbState.idle;
        _stopTimer();
      }
    });
  }

  void _startTimer() {
    _seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        // Mock amplitude for visual feedback
        _amplitude = (0.1 + (math.Random().nextDouble() * 0.9));
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _amplitude = 0.0;
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record', style: Theme.of(context).textTheme.displayLarge),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatTime(_seconds),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontFamily: 'JetBrains Mono',
              fontSize: 48,
            ),
          ),
          const SizedBox(height: 64),
          Center(
            child: RecordingOrb(
              state: _state,
              amplitude: _amplitude,
              onTap: _toggleRecording,
            ),
          ),
          const SizedBox(height: 64),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              _state == OrbState.recording 
                ? 'Tap the orb to stop recording. Your thoughts are being captured safely.'
                : 'Tap the orb to start recording. Everything stays on your device.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
