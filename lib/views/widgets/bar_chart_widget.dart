import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  final Map<String, double> monthlyData;

  const BarChartWidget({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    final maxValue = monthlyData.values.isEmpty
        ? 10000.0
        : monthlyData.values.reduce((a, b) => a > b ? a : b);
    final maxValueRounded = ((maxValue / 1000).ceil() * 1000).toDouble();

    final months = ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'];
    final yAxisLabels = [
      '0',
      '${(maxValueRounded * 0.3 / 1000).toStringAsFixed(0)}k',
      '${(maxValueRounded * 0.5 / 1000).toStringAsFixed(0)}k',
      '${(maxValueRounded * 0.8 / 1000).toStringAsFixed(0)}k',
      '${(maxValueRounded / 1000).toStringAsFixed(0)}k',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Y-axis labels and bars
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Y-axis
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: yAxisLabels.reversed.map((label) {
                return SizedBox(
                  height: 40,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        label,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            // Bars
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: months.map((month) {
                  final value = monthlyData[month] ?? 0.0;
                  final height = maxValueRounded > 0
                      ? (value / maxValueRounded) * 200
                      : 0.0;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 30,
                        height: height > 0 ? height : 0,
                        decoration: BoxDecoration(
                          color: height > 0
                              ? const Color(0xFF9EFF00) // Light green
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        month,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
