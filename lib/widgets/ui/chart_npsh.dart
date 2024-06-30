import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:npsh3/providers/npsh.dart';
import 'package:provider/provider.dart';

class ChartNPSH extends StatelessWidget {
  ChartNPSH({
    super.key,
    Color? mainLineColor,
    Color? belowLineColor,
    Color? aboveLineColor,
  })  : mainLineColor = Colors.black,
        belowLineColor = Colors.blue,
        aboveLineColor = Colors.green;

  final Color mainLineColor;
  final Color belowLineColor;
  final Color aboveLineColor;

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.green,
      fontSize: 12,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text('\$ ${value + 0.5}', style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NpshProvider npshProvider = Provider.of<NpshProvider>(context);

    return AspectRatio(
      aspectRatio: 3,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          right: 28,
          top: 22,
          bottom: 12,
        ),
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              getTouchedSpotIndicator:
                  (LineChartBarData barData, List<int> spotIndexes) {
                return spotIndexes.map((spotIndex) {
                  final spot = barData.spots[spotIndex];
                  if (spot.x == 0) {
                    return null;
                  }
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                    FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 2,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.black,
                        );
                      },
                    ),
                  );
                }).toList();
              },
              touchTooltipData: LineTouchTooltipData(
                maxContentWidth: 100,
                tooltipRoundedRadius: 4,
                fitInsideVertically: false,
                fitInsideHorizontally: false,
                tooltipBorder: const BorderSide(width: 1.0),
                getTooltipColor: (touchedSpot) => Colors.white,
                // tooltipBgColor: Colors.white,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    const textStyle = TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    );
                    return LineTooltipItem(
                      'H: ${touchedSpot.y.toStringAsFixed(2)}, Q: ${touchedSpot.x.toStringAsFixed(2)}',
                      textStyle,
                    );
                  }).toList();
                },
              ),
              handleBuiltInTouches: true,
              getTouchLineStart: (data, index) => 0,
            ),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  ...npshProvider.allNpshPoints
                      .takeWhile((value) {
                        return value.npsh3 != 0;
                      })
                      .map((point) =>
                          FlSpot(point.q.toDouble(), point.npsh3.toDouble()))
                      .toList(),
                ],
                isStrokeCapRound: false,
                isStrokeJoinRound: false,
                isCurved: true,
                dashArray: [5, 5],
                barWidth: 2,
                curveSmoothness: 0.2,
                color: Colors.red,
                dotData: FlDotData(
                  show: true,
                ),
              ),
            ],
            minY: 0,
            minX: 0,
            maxX: npshProvider.allPoints.fold(
                0,
                (previousValue, point) => previousValue! > point.qInicial
                    ? previousValue
                    : point.qInicial.toDouble() + 2),
            maxY: npshProvider.allNpshPoints.fold(
                0,
                (previousValue, point) => previousValue! > point.npsh3
                    ? previousValue
                    : point.npsh3.toDouble() + 2),
            titlesData: FlTitlesData(
              show: true,
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                axisNameWidget: const Text(
                  'Q (gpm)',
                  style: TextStyle(
                    // fontSize: 10,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                ),
              ),
              leftTitles: AxisTitles(
                axisNameSize: 20,
                axisNameWidget: const Text(
                  'NPSH3 (m)',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Colors.black,
              ),
            ),
            gridData: FlGridData(
                show: true, drawVerticalLine: true, drawHorizontalLine: true),
          ),
        ),
      ),
    );
  }
}
