import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({Key? key}) : super(key: key);

  @override
  _LineChartSample2State createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  final List<FlSpot> mainData = const [
    FlSpot(0, 3),
    FlSpot(2.6, 2),
    FlSpot(4.9, 5),
    FlSpot(6.8, 3.1),
    FlSpot(8, 4),
    FlSpot(9.5, 3),
    FlSpot(11, 4),
    FlSpot(22.4, 5),
    FlSpot(26.4, 7),
    FlSpot(33.8, 6),
    FlSpot(40.8, 2),
    FlSpot(47, 7),
    FlSpot(50, 8),
  ];
  List<FlSpot> _scrubberChartData = [];
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  double? _chartTouchedIndex;
  bool scrubberState = false;
  bool showAvg = false;

  @override
  void initState() {
    _scrubberChartData = mainData.toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(18),
          ),
          color: Colors.white),
      child: Padding(
        padding:
            const EdgeInsets.only(right: 18.0, left: 12.0, top: 24, bottom: 12),
        child: LineChart(
          mainChartView(),
        ),
      ),
    );
  }

  LineChartData mainChartView() {
    return LineChartData(
      minX: 0,
      maxX: 50,
      minY: 0,
      maxY: 8,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.white,
            tooltipRoundedRadius: 8,
            tooltipMargin: 0,
            fitInsideHorizontally: true,
            // fitInsideVertically: true,
            showOnTopOfTheChartBoxArea: true,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot e) {
                if (e.bar.show && e.bar.belowBarData.show) {
                  final String title = e.y.toString();
                  return LineTooltipItem(title,
                      const TextStyle(fontSize: 16, color: Colors.black));
                } else {
                  return null;
                }
              }).toList();
            },
            //   showOnTopOfTheChartBoxArea: true,
          ),
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((int index) {
              bool show = false;

              /// If enable scrubber, depends on the chart base line
              /// where the bellow bar data is not show
              show = !barData.belowBarData.show;

              if (show) {
                _chartTouchedIndex = index.toDouble();
              }

              return TouchedSpotIndicatorData(
                FlLine(color: show ? Colors.black : Colors.transparent),
                FlDotData(
                  show: show,
                  getDotPainter: (FlSpot spot, double percent,
                          LineChartBarData barData, int index) =>
                      FlDotCirclePainter(
                    radius: 6,
                    color: Colors.black,
                    strokeWidth: 2,
                    strokeColor: Colors.black,
                  ),
                ),
              );
            }).toList();
          },
          touchCallback:
              (FlTouchEvent event, LineTouchResponse? touchResponse) {
            _ctaChartTouchEvent(event);
          }),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(showTitles: false),
        leftTitles: SideTitles(
          showTitles: true,
          interval: 1,
          margin: MediaQuery.of(context).size.width * -0.2,
          reservedSize: MediaQuery.of(context).size.width * 0.2,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '\$ 10k';
              case 3:
                return '5%';
              case 5:
                return '-5%';
            }
            return '';
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: mainData,
          isCurved: true,
          curveSmoothness: 0.1,
          colors: [Colors.black],
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
        LineChartBarData(
          spots: _scrubberChartData,
          isCurved: true,
          colors: [Colors.transparent],
          barWidth: 4,
          curveSmoothness: 0.1,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
              show: true,
              colors: [Colors.indigo],
              spotsLine: BarAreaSpotsLine(
                  show: false,
                  flLineStyle: FlLine(strokeWidth: 2),
                  applyCutOffY: false)),
        )
      ],
    );
  }

  void _ctaChartTouchEvent(FlTouchEvent event) {
    if (_chartTouchedIndex != null) {
      if (event is FlLongPressStart ||
          event is FlPanStartEvent ||
          event is FlPanUpdateEvent ||
          event is FlLongPressMoveUpdate) {
        _enableScrubber();
      } else if (event is FlLongPressEnd || event is FlPanEndEvent) {
        _disableScrubber();
      }
    }
  }

  void _enableScrubber() {
    try {
      _scrubberChartData = mainData.toList();
      _scrubberChartData.removeRange(
        ((_chartTouchedIndex ?? 0) + 1).toInt(),
        _scrubberChartData.length,
      );
      setState(() {
        scrubberState = true;
      });
    } on Exception catch (_) {
      return;
    }
  }

  void _disableScrubber() {
    _scrubberChartData = mainData.toList();
    _chartTouchedIndex = null;
    setState(() {
      scrubberState = false;
    });
  }
}
