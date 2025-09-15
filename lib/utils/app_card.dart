import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double elevation;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 10.0,
    this.elevation = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: Colors.blue[100],
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(padding: padding, child: child),
    );

    // Wrap with InkWell only if onTap is provided
    if (onTap != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
