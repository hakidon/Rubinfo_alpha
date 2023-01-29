import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LineChartSample extends StatefulWidget {
  var _latest_price = <String, dynamic>{};
  var _predictions = <String, dynamic>{};
  LineChartSample(
      Map<String, dynamic> latest_price, Map<String, dynamic> predictions) {
    _latest_price = latest_price;
    _predictions = predictions;
  }

  @override
  _LineChartSampleState createState() => _LineChartSampleState();
}

class _LineChartSampleState extends State<LineChartSample> {
  var _latest_price;
  var _predictions;

  double getDay(String date) {
    List<String> dateList = date.split("/");
    double day = double.parse(dateList[0]);
    return day;
  }

  @override
  void initState() {
    super.initState();
    _latest_price = widget._latest_price;
    _predictions = widget._predictions;
    setSpot();
  }

  List<Color> valColors = [
    const Color(0xff23b6e6),
    const Color(0xff87CEEB),
  ];

  List<Color> predColors = [
    Color.fromRGBO(242, 52, 5, 1),
    Color.fromARGB(255, 255, 115, 0),
  ];

  List<FlSpot> spots = [];

  //Need to be odd length
  List<FlSpot> spots2 = [];

  // List<FlSpot> spots = [FlSpot(0, 0)];

  // //Need to be odd length
  // List<FlSpot> spots2 = [FlSpot(0, 0)];

  void setSpot() {
    // double aa = double.parse(sourceString);
    // _prediction_today = _predictions[_predictions.keys.toList()[1]]['Price']
    //     .toStringAsFixed(2);
    double last_day = 0;

    last_day = getDay(
        _latest_price[_latest_price.keys.toList()[_latest_price.length - 1]]
            ['Date']);

    // print(last_day);

    // print(last_day + _predictions[_predictions.keys.toList()[1]]['Day']);

    setState(() {
      // print(last_day);
      for (String key in _latest_price.keys) {
        spots.add(FlSpot(
            getDay(_latest_price[key]['Date']),
            double.parse(
                (_latest_price[key]['Bulk Latex'] / 100).toStringAsFixed(2))));
      }

      for (String key in _predictions.keys) {
        spots2.add(FlSpot(
            (_predictions[key]['Day'].toDouble() + last_day),
            double.parse(
                (_predictions[key]['Price'] / 100).toStringAsFixed(2))));
      }
    });
  }

  List<double> get_min_max_y_val() {
    List<FlSpot> allSpots = spots + spots2;
    double highestYValue = double.negativeInfinity;
    double lowestYValue = double.infinity;

    for (var spot in allSpots) {
      if (spot.y > highestYValue) {
        highestYValue = spot.y;
      } else if (spot.y < lowestYValue) {
        lowestYValue = spot.y;
      }
    }

    lowestYValue = (lowestYValue).toDouble();
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
    // print(spots);
    // print(spots2);
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
                  if (x == spots2[(spots2.length / 2).toInt()].x)
                    return "15 days\npredictions";
                  else if (x == spots[(spots.length / 2).toInt()].x) {
                    if (spots.length == 2 || spots.length == 1)
                      return "";
                    else
                      return "Monthly data";
                  } else
                    return "";
                }),
            leftTitles: SideTitles(
                interval:
                    0.1, //-------------------------------------------------------------------------------
                showTitles: true,
                getTextStyles: (val) => const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                getTitles: (y) {
                  return y.toStringAsFixed(1);
                })),
        minX: spots[0].x,
        maxX: spots2[spots2.length - 1].x,
        minY: lowestY,
        maxY: highestY,
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: 0.1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey, strokeWidth: 0.8);
          },
          checkToShowHorizontalLine: (value) {
            return true;
          },
          drawVerticalLine: false,
        ),
        lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
            bool first = true;
            return lineBarsSpot.map((lineBarSpot) {
              if (first) {
                first = false;
                int currentMonth = DateTime.now().month;
                int currentYear = DateTime.now().year;
                double x_temp = lineBarSpot.x;
                if (lineBarSpot.x > lastDay) {
                  x_temp -= lastDay;
                  currentMonth += 1;
                  if (currentMonth > 12) {
                    currentYear += 1;
                    currentMonth = 1;
                  }
                }

                String tooltipText = 'RM ' +
                    lineBarSpot.y.toString() +
                    '\n' +
                    x_temp.toStringAsFixed(0) +
                    '/' +
                    currentMonth.toString() +
                    '/' +
                    currentYear.toString();

                return LineTooltipItem(
                  tooltipText,
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
            }).toList();
          },
          tooltipBgColor: Colors.blueGrey,
        )),
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
              )),
          LineChartBarData(
              spots: spots2,
              isCurved: true,
              colors: predColors,
              barWidth: 5,
              belowBarData: BarAreaData(
                show: true,
                colors: predColors.map((e) => e.withOpacity(0.3)).toList(),
              ),
              dotData: FlDotData(
                show: true,
              )),
        ]));
  }
}
