import 'package:flutter/material.dart';

Future<void> showWASlidePanel({required BuildContext context, required Widget child, double width = 720}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Details',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, __, ___) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: width,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
              boxShadow: [BoxShadow(blurRadius: 40, offset: const Offset(-10, 0), color: Colors.black.withValues(alpha: 0.25))],
            ),
            child: child,
          ),
        ),
      );
    },
    transitionBuilder: (_, animation, __, child) {
      final slide = Tween(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(position: slide, child: child);
    },
  );
}
