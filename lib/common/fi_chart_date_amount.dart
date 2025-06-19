import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


class CustomBarChart extends StatefulWidget {
  @override
  _CustomBarChartState createState() => _CustomBarChartState();
}

class _CustomBarChartState extends State<CustomBarChart>
    with SingleTickerProviderStateMixin {
  final List<double> data = [
    5,
    8,
    12,
    7,
    10,
    14,
    9,
    18,
    20,
    22,
    45,
    100,
    60,
    70,
    25,
    30,
    50,
    40,
    35,
    55,
    75,
    65,
    80,
    85,
    90,
    20,
    15,
    10,
    8,
    25,
    18
  ];

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<BarChartGroupData> _buildAnimatedBars(double animationValue) {
    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index] * animationValue,
            color: Colors.green,
            width: 6,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return BarChart(
                  BarChartData(
                    maxY: 100,
                    minY: 0,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 20,
                          reservedSize: 30,
                          getTitlesWidget: (value, _) => Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black),
                          ),
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, _) {
                            int day = value.toInt() + 1;
                            if (day % 2 == 0) {
                              return Text('$day',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.black));
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData:
                        const FlGridData(show: true, horizontalInterval: 20),
                    barGroups: _buildAnimatedBars(_animation.value),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// class CustomBarChart extends StatelessWidget {
//   final List<double> data = [
//     5, 8, 12, 7, 10, 14, 9, 18, 20, 22,
//     45, 100, 60, 70, 25, 30, 50, 40, 35, 55,
//     75, 65, 80, 85, 90, 20, 15, 10, 8, 25, 18
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal:  8.0),
//       child: Column(
//         children: [
//           const SizedBox(height: 12,),
          
          
//           SizedBox(
//             height: 220,
//             child: BarChart(
//               BarChartData(
//                 maxY: 100,
//                 minY: 0,
//                 barTouchData: BarTouchData(enabled: false),
//                 titlesData: FlTitlesData(
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       interval: 20,
//                       reservedSize: 30,
//                       getTitlesWidget: (value, _) => Text(
//                         value.toInt().toString(),
//                         style: const TextStyle(fontSize: 10, color: Colors.black),
//                       ),
//                     ),
//                   ),
//                   rightTitles: const AxisTitles(
//                     sideTitles: SideTitles(showTitles: false), // Disabled right titles
//                   ),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       interval: 1,
//                       getTitlesWidget: (value, _) {
//                         int day = value.toInt() + 1;
//                         if (day % 2 == 0) {
//                           return Text('$day', style: const TextStyle(fontSize: 10, color: Colors.black));
//                         }
//                         return const SizedBox.shrink();
//                       },
//                     ),
//                   ),
//                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // No top titles
//                 ),
//                 borderData: FlBorderData(show: false),
//                 gridData: const FlGridData(show: true, horizontalInterval: 20),
//                 barGroups: List.generate(data.length, (index) {
//                   return BarChartGroupData(
//                     x: index,
//                     barRods: [
//                       BarChartRodData(
//                         toY: data[index],
//                         color: Colors.green,
//                         width: 6,
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ],
//                   );
//                 }),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


 