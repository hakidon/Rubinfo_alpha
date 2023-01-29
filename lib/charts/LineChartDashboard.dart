import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartDashboard extends StatefulWidget {

  var _latest_price = <String, dynamic>{};

  LineChartDashboard(Map<String, dynamic> latest_price) {
    _latest_price = latest_price;
  }

  @override
  _LineChartDashboardState createState() => _LineChartDashboardState();
}

class _LineChartDashboardState extends State<LineChartDashboard> {
  var _latest_price;

  double getDay(String date) {
    List<String> dateList = date.split("/");
    double day = double.parse(dateList[0]);
    return day;
  }

  @override
  void initState() {
    super.initState();
    _latest_price = widget._latest_price;
    setSpot();
  }

  List<Color> valColors = [
    const Color(0xff23b6e6),
    const Color(0xff87CEEB),
  ];

  List<FlSpot> spots = [];

  void setSpot() {
    double last_day = 0;

    last_day = getDay(_latest_price[_latest_price.keys.toList()[_latest_price.length - 1]]
    ['Date']);

    setState(() {
      for (String key in _latest_price.keys) {
        spots.add(FlSpot(getDay(_latest_price[key]['Date']),
      (_latest_price[key]['Bulk Latex']).toDouble()));
      }
    });
  }

  List<double> get_min_max_y_val() {
    List<FlSpot> allSpots = spots;
    double highestYValue = double.negativeInfinity;
    double lowestYValue = double.infinity;

    for (var spot in allSpots) {
      if (spot.y > highestYValue) {
        highestYValue = spot.y;
      } else if (spot.y < lowestYValue) {
        lowestYValue = spot.y;
      }
    }

   lowestYValue = (lowestYValue ~/ 10 * 10).toDouble();


  return [lowestYValue, highestYValue];
  }

  int lastDayOfMonth(int month, int year) {
    bool _isLeapYear(int year) {
      if (year % 4 != 0) {
        return false;
      } else if (year % 100 != 0) {
        return true;
      } else if (year % 400 != 0) {
        return false;
      } else {
        return true;
      }
    }

    if (month < 1 || month > 12) {
      throw Exception('Invalid month');
    }
    if (year < 1) {
      throw Exception('Invalid year');
    }
    int lastDay;
    if (month == 2) {
      if (_isLeapYear(year)) {
        lastDay = 29;
      } else {
        lastDay = 28;
      }
    } else if (month == 4 || month == 6 || month == 9 || month == 11) {
      lastDay = 30;
    } else {
      lastDay = 31;
    }
    return lastDay;
  }

  @override
  Widget build(BuildContext context) {

    List<double> y_val = get_min_max_y_val();
    final lowestY = y_val[0];
    final highestY = y_val[1];
    final lastDay = lastDayOfMonth(DateTime.now().month, DateTime.now().year);
    return LineChart(LineChartData(
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (val) => const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
            getTitles: (x) {
              if (x == spots[(spots.length / 2).toInt()].x) {
                if (spots.length == 2 || spots.length == 1)
                  return "";
                else
                  return "Monthly data";
              } else
                return "";
            }),
        leftTitles: SideTitles(
          interval: 10,
          showTitles: true,
          getTextStyles: (val) => const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (y) {
            return y.toInt().toString();
          })),
      minX: 0,
      maxX: spots[spots.length - 1].x,
      minY: lowestY,
      maxY: highestY,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
            bool first = true;
            return lineBarsSpot.map((lineBarSpot) {
              if (first){
                first = false;
                int currentMonth = DateTime.now().month;
                int currentYear = DateTime.now().year;
                double x_temp = lineBarSpot.x;
                if (lineBarSpot.x > lastDay) {
                  x_temp -= lastDay;
                  currentMonth ++;
                  if (currentMonth > 12) {
                    currentYear +=1;
                    currentMonth = 1;
                  }
                }

                String tooltipText = 'RM' +
                    lineBarSpot.y.toString() +
                    '\n' +
                    x_temp.toStringAsFixed(0) +
                    '/' +
                    currentMonth.toString() +
                    '/' +
                    currentYear.toString();

                return LineTooltipItem(
                  tooltipText,
                  const TextStyle(color: Colors.white),
                );
              }
            }).toList();
          },
          tooltipBgColor: Colors.blueGrey,
        )
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          colors: valColors,
          barWidth: 5,
          belowBarData: BarAreaData(
            show: true,
            colors: valColors.map((e) => e.withOpacity(0.3)).toList(),
          ),
          dotData: FlDotData(
            show: true,
          )
        ),
      ],
    ));
  }
}
