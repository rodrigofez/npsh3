import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:npsh3/providers/npsh.dart';
import 'package:provider/provider.dart';

class CavitacionChart extends StatelessWidget {
  const CavitacionChart({
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

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Jan';
        break;
      case 1:
        text = 'Feb';
        break;
      case 2:
        text = 'Mar';
        break;
      case 3:
        text = 'Apr';
        break;
      case 4:
        text = 'May';
        break;
      case 5:
        text = 'Jun';
        break;
      case 6:
        text = 'Jul';
        break;
      case 7:
        text = 'Aug';
        break;
      case 8:
        text = 'Sep';
        break;
      case 9:
        text = 'Oct';
        break;
      case 10:
        text = 'Nov';
        break;
      case 11:
        text = 'Dec';
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: mainLineColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

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
      aspectRatio: 2,
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
                    const FlLine(
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
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    const textStyle = TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    );
                    return LineTooltipItem(
                      'Q: ${touchedSpot.x}, H: ${touchedSpot.y.toStringAsFixed(2)}',
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
                  ...npshProvider.allPoints
                      .takeWhile((value) {
                        return value.qInicial != 0;
                      })
                      .map((point) => FlSpot(
                          point.qInicial.toDouble(), point.hNeta.toDouble()))
                      .toList(),
                ],
                isStrokeCapRound: false,
                isStrokeJoinRound: false,
                isCurved: true,
                barWidth: 2,
                color: mainLineColor,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 2,
                    color: Colors.black,
                    strokeWidth: 2,
                    strokeColor: mainLineColor,
                  ),
                ),
              ),
              LineChartBarData(
                spots: [
                  ...npshProvider.allPoints
                      .takeWhile((value) {
                        return value.qInicial != 0;
                      })
                      .map((point) => FlSpot(point.qInicial.toDouble(),
                          point.hNeta.toDouble() * 0.97))
                      .toList(),
                ],
                isStrokeCapRound: false,
                isStrokeJoinRound: false,
                isCurved: true,
                dashArray: [5, 5],
                barWidth: 2,
                curveSmoothness: 0.2,
                color: Colors.red,
                dotData: const FlDotData(
                  show: false,
                ),
              ),
              ...npshProvider.allObservationPoints.map((observationPoint) {
                return LineChartBarData(
                  spots: [
                    ...observationPoint
                        .takeWhile((value) =>
                            value.hExperimental != 0 && value.qInicial != 0)
                        .map((point) => FlSpot(point.qInicial.toDouble(),
                            point.hExperimental.toDouble()))
                        .toList(),
                  ],
                  isStrokeCapRound: false,
                  isStrokeJoinRound: false,
                  isCurved: true,
                  // dashArray: [5, 5],
                  barWidth: 2,
                  color: Colors.blue,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 2,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: Colors.blue,
                    ),
                  ),
                );
              })
            ],
            minY: 0,
            minX: 0,
            maxX: npshProvider.allPoints.fold(
                0,
                (previousValue, point) => previousValue! > point.qInicial
                    ? previousValue
                    : point.qInicial.toDouble() + 2),
            maxY: npshProvider.allPoints.fold(
                0,
                (previousValue, point) => previousValue! > point.hNeta
                    ? previousValue
                    : point.hNeta.toDouble() + 2),
            titlesData: const FlTitlesData(
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
                  'H (m)',
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
            gridData: const FlGridData(
                show: true, drawVerticalLine: true, drawHorizontalLine: true),
          ),
        ),
      ),
    );
  }
}
