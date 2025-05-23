import 'package:flutter/material.dart';
import 'dart:math';

enum TransitionType { fade, flip, cardSwap }

Route createPageTransition(Widget page,
    {int time = 1200, TransitionType transitionType = TransitionType.fade}) {
  return PageRouteBuilder(
    transitionDuration: Duration(milliseconds: time),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      switch (transitionType) {
        case TransitionType.flip:
          return AnimatedBuilder(
            animation: animation,
            child: child,
            builder: (context, child) {
              final rotateY = Tween<double>(begin: pi, end: 0).animate(animation);
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateY(rotateY.value),
                child: child,
              );
            },
          );

        case TransitionType.cardSwap:
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1.0, 0.0), // Start from the right
              end: Offset.zero,
            ).animate(animation),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
              child: child,
            ),
          );

        case TransitionType.fade:
        // default:
          return FadeTransition(
            opacity: animation,
            child: child,
          );
      }
    },
  );
}
