import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BreathingFlower extends StatefulWidget {
  final Duration inhaleDuration;
  final Duration exhaleDuration;

  const BreathingFlower({
    required this.exhaleDuration,
    required this.inhaleDuration,
    super.key
  });

  @override
  State<BreathingFlower> createState() => _BreathingFlowerState();
}

class _BreathingFlowerState extends State<BreathingFlower> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _cycleTimer;
  Timer? _secondTicker;

  bool isInhaling = true;
  int secondsRemaining = 0;

  @override
  void initState() {
    // TODO: implement initState
    _controller = AnimationController(
        vsync: this,
      duration: widget.inhaleDuration,
    );

    _animation =  Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );

    secondsRemaining = widget.inhaleDuration.inSeconds;
    _startSecondTicker();
    _startBreathingLoop();

    super.initState();
  }

  void _startBreathingLoop(){
      _controller.forward();
      _cycleTimer = Timer.periodic(widget.inhaleDuration + widget.exhaleDuration, (timer){
        _breatheIn();
        Future.delayed(widget.inhaleDuration, (){
            _breatheOut();
        });
      });
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
    _secondTicker = Timer.periodic(Duration(seconds: 1), (_) {
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
    _cycleTimer?.cancel();
    _secondTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: child,
            );
          },
          child: SvgPicture.asset('assets/flower.svg', width: 250),
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
