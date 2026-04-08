import 'dart:math' as math;
import 'package:flutter/material.dart';

enum OrbState { idle, recording, processing, paused }

class RecordingOrb extends StatefulWidget {
  const RecordingOrb({
    super.key,
    required this.state,
    this.amplitude = 0.0,
    this.onTap,
  });

  final OrbState state;
  final double amplitude; // 0.0 to 1.0
  final VoidCallback? onTap;

  @override
  State<RecordingOrb> createState() => _RecordingOrbState();
}

class _RecordingOrbState extends State<RecordingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _breathingController,
        builder: (context, child) {
          final scale = 1.0 + (_breathingController.value * 0.04);
          
          return CustomPaint(
            painter: OrbPainter(
              state: widget.state,
              breathingValue: _breathingController.value,
              amplitude: widget.amplitude,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: SizedBox(
              width: 180,
              height: 180,
              child: Center(
                child: _buildIcon(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIcon() {
    switch (widget.state) {
      case OrbState.idle:
        return const Icon(Icons.mic, size: 48, color: Colors.white);
      case OrbState.recording:
        return const Icon(Icons.stop, size: 48, color: Colors.white);
      case OrbState.processing:
        return const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        );
      case OrbState.paused:
        return const Icon(Icons.play_arrow, size: 48, color: Colors.white);
    }
  }
}

class OrbPainter extends CustomPainter {
  OrbPainter({
    required this.state,
    required this.breathingValue,
    required this.amplitude,
    required this.color,
  });

  final OrbState state;
  final double breathingValue;
  final double amplitude;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2.5;

    // Background Glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.15 + (breathingValue * 0.1))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    
    canvas.drawCircle(center, baseRadius * 1.2, glowPaint);

    // Main Orb
    final orbPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.9),
          color,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius));

    final orbRadius = baseRadius * (1.0 + (breathingValue * 0.04));
    canvas.drawCircle(center, orbRadius, orbPaint);

    // Amplitude Waves (Recording only)
    if (state == OrbState.recording) {
      final wavePaint = Paint()
        ..color = color.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final waveRadius = baseRadius + (amplitude * baseRadius * 0.8);
      canvas.drawCircle(center, waveRadius, wavePaint);
      
      final outerWaveRadius = baseRadius + (amplitude * baseRadius * 1.2);
      wavePaint.color = color.withOpacity(0.2);
      canvas.drawCircle(center, outerWaveRadius, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant OrbPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.breathingValue != breathingValue ||
        oldDelegate.amplitude != amplitude;
  }
}
