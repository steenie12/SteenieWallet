import 'dart:math' as math;
import 'package:flutter/material.dart';

class VelarioLoadingAnimation extends StatefulWidget {
  const VelarioLoadingAnimation({super.key, this.size = 112});

  final double size;

  @override
  State<VelarioLoadingAnimation> createState() =>
      _VelarioLoadingAnimationState();
}

class _VelarioLoadingAnimationState extends State<VelarioLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = 0.94 + 0.06 *
            math.sin(_controller.value * math.pi * 2);

        return SizedBox(
          width: widget.size,
          height: widget.size + 38,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: pulse,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: widget.size * 0.72,
                        height: widget.size * 0.72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF8A35).withValues(alpha: 0.10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF8A35)
                                  .withValues(alpha: 0.28),
                              blurRadius: 32,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      Transform.rotate(
                        angle: _controller.value * math.pi * 2,
                        child: Container(
                          width: widget.size * 0.92,
                          height: widget.size * 0.92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFA45E)
                                  .withValues(alpha: 0.55),
                              width: 1.5,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFA45E),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: widget.size * 0.66,
                        height: widget.size * 0.66,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(23),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFB36B),
                              Color(0xFFFF7628),
                              Color(0xFFB84916),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF7628)
                                  .withValues(alpha: 0.35),
                              blurRadius: 20,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'V',
                            style: TextStyle(
                              fontSize: 43,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1,
                              letterSpacing: -3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'VELARIO',
                style: TextStyle(
                  color: Color(0xFFFFA45E),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
