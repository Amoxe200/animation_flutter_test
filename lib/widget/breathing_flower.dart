import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class BreathingFlower extends StatefulWidget {
  final Duration inhaleDuration;
  final Duration exhaleDuration;

  const BreathingFlower({
    super.key,
    this.inhaleDuration = const Duration(seconds: 6),
    this.exhaleDuration = const Duration(seconds: 6),
  });

  @override
  State<BreathingFlower> createState() => _BreathingFlowerState();
}

class _BreathingFlowerState extends State<BreathingFlower> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Timer _cycleTimer;
  late Timer _secondTicker;

  bool isInhaling = true;
  int secondsRemaining = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.inhaleDuration);
    secondsRemaining = widget.inhaleDuration.inSeconds;

    _startBreathingLoop();
    _startSecondTicker();
  }

  void _startBreathingLoop() {
    _controller.forward(from: 0);

    _cycleTimer = Timer.periodic(
      widget.inhaleDuration + widget.exhaleDuration,
          (_) {
        _breatheIn();
        Future.delayed(widget.inhaleDuration, () => _breatheOut());
      },
    );
  }

  void _breatheIn() {
    setState(() {
      isInhaling = true;
      secondsRemaining = widget.inhaleDuration.inSeconds;
    });
    _controller.duration = widget.inhaleDuration;
    _controller.forward(from: 0);
  }

  void _breatheOut() {
    setState(() {
      isInhaling = false;
      secondsRemaining = widget.exhaleDuration.inSeconds;
    });
    _controller.duration = widget.exhaleDuration;
    _controller.reverse(from: 1);
  }

  void _startSecondTicker() {
    _secondTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _cycleTimer.cancel();
    _secondTicker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/animation.json',
          controller: _controller,
          height: 300,
          repeat: false,
          onLoaded: (composition) {
            _controller.duration = isInhaling ? widget.inhaleDuration : widget.exhaleDuration;
          },
        ),
        const SizedBox(height: 24),
        Text(
          '${isInhaling ? "Inhale" : "Exhale"}... $secondsRemaining',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
