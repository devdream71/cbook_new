import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DonutChartViewRound extends StatefulWidget {
  @override
  _DonutChartViewRoundState createState() => _DonutChartViewRoundState();
}

class _DonutChartViewRoundState extends State<DonutChartViewRound>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<double> values = [40, 20, 15, 25];
  final List<Color> colors = [
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.blue,
  ];

  final List<String> labels = [
    'Sales',
    'Purchase',
    'Receive',
    'Payment',
  ];

  final List<String> legendLabels = [
    "30,12,256",
    "40,11,256",
    "20,65,44",
    "31,57,569",
  ];

  double get totalValue => values.reduce((a, b) => a + b);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<PieChartSectionData> _buildAnimatedSections(double sweepPercent) {
    double sweepTotal = totalValue * sweepPercent;
    double consumed = 0;

    List<PieChartSectionData> animatedSections = [];

    for (int i = 0; i < values.length; i++) {
      double remaining = sweepTotal - consumed;
      double currentValue = values[i];

      if (remaining <= 0) {
        break;
      }

      double shownValue = remaining >= currentValue ? currentValue : remaining;

      animatedSections.add(
        PieChartSectionData(
          color: colors[i],
          value: shownValue,
          title: shownValue >= currentValue
              ? "${labels[i]}\n${values[i].toInt()}%"
              : "", // hide partial labels
          radius: 39,
          titleStyle: const TextStyle(
              fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );

      consumed += shownValue;
    }

    return animatedSections;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Center(
        child: Wrap(
          spacing: 20,
          runSpacing: 46,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Donut Chart with sweep animation
            SizedBox(
              width: 170,
              height: 170,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return PieChart(
                    PieChartData(
                      sections: _buildAnimatedSections(_animation.value),
                      centerSpaceRadius: 35,
                      sectionsSpace: 2,
                      startDegreeOffset: -90,
                    ),
                  );
                },
              ),
            ),

            // Legend
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(legendLabels.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        color: colors[index],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        legendLabels[index],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
