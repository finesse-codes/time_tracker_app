import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class TaskProgressIndicator extends StatelessWidget {
  final int completed;
  final int total;
  final double height;
  final double radius;

  const TaskProgressIndicator({
    super.key,
    required this.completed,
    required this.total,
    this.height = 8.0,
    this.radius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : completed / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircularPercentIndicator(
          percent: percent.clamp(0.0, 1.0),
          backgroundColor: Colors.grey.shade300,
          progressColor: Colors.blue,
          radius: 60.0,
          lineWidth: 10.0,
          center: Center(
            child: Text(
              "$completed of $total \ntasks",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
